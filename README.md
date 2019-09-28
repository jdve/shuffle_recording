# shuffle_recording
When using an audio recording for learning drills (e.g., language sessions), it
is often helpful to listen to the recordings out-of-order to better engage with
the material.  This tool finds the segments of an audio file by locating the
silence breaks, and then creates a new file with these segments reordered
randomly.  In addition, it repeats all the segments multiple times to make a
longer, more challenging recording.

## Usage

### MacOS Finder
1. Download the [latest release](https://github.com/jdve/shuffle_recording/releases).
2. Unzip the release.
3. Double-click `Shuffle Recording.workflow` to install.
4. Right-click on any number of audio files in Finder.
5. Choose the "Shuffle Recording" option from the "Quick Actions" menu.

![Using MacOS Finder](doc/finder.gif)

### Terminal
Alternatively, you can run the command line tool from the terminal.  This is
useful if you want to do more advanced scripting.

![Using Terminal](doc/terminal.gif)

## Development
While this tool is packaged for MacOS as a convenient Finder Quick Action, the
core is written using [nim](https://nim-lang.org), a cross-platform programming
language.  This means that it's quite possible to use it on other platforms as
well.  If you're interested in contributing, please feel free to submit a pull
request.

To build it, first install nim using `brew install nim`.  Then run
`./build.sh`.  This will compile the tool as well as repackage the Finder Quick
Action with the new version.  To see more details about command line options,
run `./bin/shuffle_recording --help`.

