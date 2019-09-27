# shuffle_recording
When using an audio recording for learning drills (e.g., language sessions), it is
often helpful to listen to the recordings out-of-order to better engage with the
material.  This tool finds the segments of an audio file by locating the silence
breaks, and then creates a new file with these segments reordered randomly.  In
addition, it repeats all the segments multiple times to make a longer, more
challenging recording.

# Install on MacOS
1. Download the [latest release](https://github.com/jdve/shuffle_recording/releases).
2. Unzip the release.
3. Double-click `Shuffle Recording.workflow` to install.

# Using in Finder 
1. In Finder, right-click on any number of audio files.
2. Choose "Shuffle Recording" from the "Quick Actions" menu.

# Other Platforms
While this tool is packaged for MacOS as a convenient Finder Quick Action, the core
is written using [nim](https://nim-lang.org), a cross-platform programming language.
This means that it's quite possible to use it on other platforms as well.  If you're
interested in contributing, please let me know.

# Developing
To build it, first install nim using `brew install nim`.  To build it, run `./build.sh`.
This will compile the tool as well as repackage the Finder Quick Action with the new
version.  To see more details about command line options, run `./shuffle_recording --help`.
