## DupeGuru CSV Handler

A utility to easily process CSV files output by DupeGuru. Displays all duplicate groups and allows the user to choose which image they want to delete

### Generating a CSV File
To generate a CSV file using DupeGuru 4.3.1, 
**On Windows, MacOS, (and probably Linux but I haven't checked)**:
- For best results, set Application Mode to Picture
- Perform a Normal scan on the folder of your choice
- For best results, activate all columns under the Columns menu
- In the File menu, select Export to CSV

### Setting up Python
To get file properties, the handler will attempt to run a Python script to get around Godot's internal limitations. This is not required, but Godot will not be able to tell which file is oldest without access to Python
**On Windows**
blah
**On MacOS**
Download the latest PKG for Python 3.x [here](https://www.python.org/downloads/macos/)
Install as normal
In the Applications folder (usually `/Applications/Python 3.x`), run `Update Shell Profile`
Test that Python was installed correctly by opening a terminal and running

    python3 --version

If you see the Python version in the terminal, then everything is fine
**On Linux**
blah