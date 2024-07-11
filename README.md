## DupeGuru CSV Handler

A utility to easily process CSV files output by DupeGuru. Displays all duplicate groups and allows the user to choose which image they want to delete

### Generating a CSV File
To generate a CSV file using DupeGuru 4.3.1 (available [here](https://github.com/arsenetar/dupeguru)), 
**On Windows, MacOS, (and probably Linux but I haven't checked)**:
- For best results, set Application Mode to Picture
- Perform a Normal scan on the folder of your choice
- For best results, activate all columns under the Columns menu
- In the File menu, select Export to CSV

### Gallery-dl compatibility
If the images were downloaded via gallery-dl (available [here](https://github.com/mikf/gallery-dl)), image creation dates can be extracted from twitter's API instead of getting the file creation date.

To set this up, follow gallery-dl's configuration instructions and create a `config.json` or `gallery-dl.conf` in the proper place.

To retrieve JSON metadata along with images, you can fill your config fill with a setup like this

```angular2html
{
    "extractor": {
        "base-directory": "C:\path\to\archive\",
        "twitter": {
            "username": "",
            "password": "",
            "skip":"exit:3",
            "text-tweets":false,
            "quoted":false,
            "retweets":false,
            "filename": "{author[name]}-{tweet_id}-{num}.{extension}",
            "postprocessors":[
                {"name": "metadata", "event": "post", "filename": "{author[name]}-{tweet_id}.json"}
            ]
        },
        "mastodon": {
            "metadata":true,
            "skip":"exit:3",
            "filename" : "artist({account[username]})-{id}-{media[id]}.{extension}",
            "directory": {
            "locals().get('bkey')": ["mastodon-{instance}", "{bkey}"],
            "": ["mastodon-{instance}", "{account[username]}"]
            },
            "postprocessors":[
            {"name": "metadata", "event": "post", "filename": "artist({account[username]})-{id}.json"}
            ]
        },
    }
}
```
The important lines here are these two.
> "filename": "{author[name]}-{tweet_id}-{id}.{extension}",
> 
> {"name": "metadata", "event": "post", "filename": "{author[name]}-{tweet_id}.json"}

If `filename` ends in `{whatever}-{idendifier}.{extension}` and metadata `filename` matches `{whatever}.json`, then the JSON will be detected properly. The only important thing here is that the image filename matches the JSON, but with a hyphen and a string at the end.

If gallery-dl metadata is detected, two main things will happen

- Instead of using Python to get file creation date, the twitter publish date will be used to determine image age
- If ALL images for a specific tweet are deleted, the JSON file will also be deleted.

### Setting up Python
To get file properties, the handler will attempt to run a Python script to get around Godot's internal limitations. This is not required, but Godot will not be able to tell which file is oldest without access to Python

#### On Windows

blah

#### On MacOS

- Download the latest PKG for Python 3.x [here](https://www.python.org/downloads/macos/)

- Install as normal

- In the Applications folder (usually `/Applications/Python 3.x`), run `Update Shell Profile`

- Test that Python was installed correctly by opening a terminal and running

> python3 --version

- If you see the Python version in the terminal, then everything is fine

#### On Linux

blah