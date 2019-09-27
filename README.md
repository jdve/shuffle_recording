# shuffle_recording
When using an audio recording for learning drills (e.g., language sessions), it is
often helpful to listen to the recordings out-of-order to better engage with the
material.  This tool finds the segments of an audio file by locating the silence
breaks, and then creates a new file with these segments reordered randomly.  In
addition, it repeats all the segments multiple times to make a longer, more
challenging recording.

# usage
This tool includes a MacOS Finder Quick Action that makes it easy to right-click on
one or more audio files to shuffle them.  To install, double-click on
`Shuffle Recording.workflow`.  After that, right-click on any number of files in
Finder and choose "Shuffle Recording" from the "Quick Actions" menu.

# advanced
This tool is written using [nim](https://nim-lang.org).  To build it, first install
nim using `brew install nim`.  To build it, run `./build.sh`.  This will compile the
tool as well as repackage the Finder Quick Action with the new version.  To see more
details about command line options, run `./shuffle_recording --help`.
