import files
import ffmpeg
import nre
import options
import os
import random
import sequtils
import strformat
import strutils
import terminal

import std/exitprocs

type Segment* = object
  startTime: float
  endTime: Option[float]

proc locateSegments(file: string, silenceSecs: float): seq[Segment] =
  ## Locate segments of audio separated by silence.
  let output = ffmpeg(
    "-i",
    file,
    "-af",
    "silencedetect=noise=-30dB:d=" & $silenceSecs,
    "-f",
    "null",
    "-")

  let pattern = re"(?s)silence_start: ([\d.]+).*?silence_end: ([\d.]+)"

  var lastMidpoint: float = 0.0

  for match in output.findIter(pattern):
    let startTime = parseFloat(match.captures[0])
    let endTime = parseFloat(match.captures[1])
    let midpoint = startTime + (endTime - startTime) / 2

    result.add(Segment(startTime: lastMidpoint, endTime: some(midpoint)))

    lastMidpoint = midpoint

  result.add(Segment(startTime: lastMidpoint))

proc extractSegment(file: string, outputAudioFile: string, segment: Segment): string =
  ## Extract a segment out of an audio file.
  if segment.endTime.isSome:
    return ffmpeg(
      "-ss", $segment.startTime,
      "-t", $(segment.endTime.get() - segment.startTime),
      "-i", file,
      "-codec", "copy",
      "-y", outputAudioFile)
  else:
    return ffmpeg(
      "-ss", $segment.startTime,
      "-i", file,
      "-codec", "copy",
      "-y", outputAudioFile)

proc joinFiles(inputFiles: seq[string], outputFile: string): string =
  ## Concatenate a bunch of audio files together.
  var args: seq[string]
  var filter = "aevalsrc=exprs=0:d=1s[silence1], aevalsrc=exprs=0:d=1s[silence2], [silence1]"
  var i = 0

  for f in inputFiles:
    args.add("-i")
    args.add(f)
    filter.add(fmt"[{i}:a:0]")
    i += 1

  filter.add(fmt"[silence2] concat=n={i+2}:v=0:a=1[outa]")

  args.add("-filter_complex")
  args.add(filter)
  args.add("-map")
  args.add("[outa]")
  args.add("-map")
  args.add("0:v:0?")
  args.add("-map_metadata")
  args.add("0")
  args.add("-y")
  args.add(outputFile)

  return ffmpeg(args)

proc randomToMax(max: int): seq[int] =
  ## Return a list of numbers from 0 to max - 1 in random order.
  result = toSeq(0..<max)
  shuffle(result)

proc process(file: string, repeatTimes: int, silenceSecs: float): string =
  ## Process an individual file.
  let (dir, name, ext) = splitFile(file)
  let segments = locateSegments(file, silenceSecs)
  var index = 1
  var segmentFiles: seq[string]

  for segment in segments:
    var segmentFile = getUniqueFile(dir, fmt"{name} ({index})", ext)

    if segment.endTime.isSome:
      styledEcho(fmt"  segment {index}: {segment.startTime:.2f}s - {segment.endTime.get():.2f}s")
    else:
      styledEcho(fmt"  segment {index}: {segment.startTime:.2f}s - end")

    discard extractSegment(file, segmentFile, segment)

    segmentFiles.add(segmentFile)

    index = index + 1

  let randomizedGroups = newSeqWith(repeatTimes, randomToMax(len(segments)))
  let randomizedIndexes = concat(randomizedGroups)
  let randomizedFiles = randomizedIndexes.mapIt(segmentFiles[it])

  styledEcho(fmt"  new file with random segments (repeated {repeatTimes} times):")
  for group in randomizedGroups:
    let forDisplay = join(group.mapIt(it + 1), ",")
    styledEcho(fmt"    {forDisplay}")

  let newFilename = getUniqueFile(dir, name & " (" & $repeatTimes & " repeats)", ext)

  discard joinFiles(randomizedFiles, newFilename)

  removeFiles(randomizedFiles)

proc main(files: seq[string], repeatTimes: int = 3, silenceSecs: float = 1.0) =
  for file in files:
    styledEcho(fgGreen, file)
    discard process(file, repeatTimes, silenceSecs)

when isMainModule:
  randomize()

  exitprocs.addExitProc(resetAttributes)

  import cligen
  dispatch(main, "shuffle_recording",
    doc = """
      When using an audio recording for learning drills (e.g., language sessions), it is
      often helpful to listen to the recordings out-of-order to better engage with the
      material.  This tool finds the segments of an audio file by locating the silence
      breaks, and then creates a new file with these segments reordered randomly.  In
      addition, it repeats all the segments multiple times to make a longer, more
      challenging recording.
    """,
    help = {
      "files": "input audio file(s)",
      "repeatTimes": "number of times to repeat each section",
      "silenceSecs": "seconds of silence required between segments"
    })

