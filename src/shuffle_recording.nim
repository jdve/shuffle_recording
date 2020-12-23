import files
import ffmpeg
import nre
import os
import random
import sequtils
import strformat
import strutils
import terminal

type Segment* = object
  startTime: float
  endTime: float

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

  var lastMidpoint: float
  var isFirst = true

  for match in output.findIter(pattern):
    let startTime = parseFloat(match.captures[0])
    let endTime = parseFloat(match.captures[1])
    let midpoint = startTime + (endTime - startTime) / 2

    if not isFirst:
      result.add(Segment(startTime: lastMidpoint, endTime: midpoint))

    lastMidpoint = midpoint
    isFirst = false

proc extractSegment(file: string, outputAudioFile: string, segment: Segment): string =
  ## Extract a segment out of an audio file.
  return ffmpeg(
    "-ss", $segment.startTime,
    "-t", $(segment.endTime - segment.startTime),
    "-i", file,
    "-codec", "copy",
    "-y", outputAudioFile)

proc joinFiles(inputFiles: seq[string], outputFile: string): string =
  ## Concatenate a bunch of audio files together.
  return ffmpeg(
    "-i", "concat:" & join(inputFiles, "|"),
    "-codec", "copy",
    "-y", outputFile)

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

    styledEcho(fmt"  segment {index}: {segment.startTime:.2f}s - {segment.endTime:.2f}s")

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

  system.addQuitProc(resetAttributes)

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

