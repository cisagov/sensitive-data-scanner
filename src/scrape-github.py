#!/usr/bin/env python3

"""Scrapes government.github.com for a list of federal organizations."""

# Standard Python Libraries
from urllib.request import urlopen

# Third-Party Libraries
from bs4 import BeautifulSoup

URL = "https://government.github.com/community/#governments-us-federal"

with urlopen(URL) as f:  # nosec
    contents = f.read()
soup = BeautifulSoup(contents, "html.parser")

fed_section = soup.find("div", id="type-governments-us-federal")


fed_divs = fed_section.find_all("div", class_="org-name")
for i in fed_divs:
    # strip leading @ from names
    print(i.contents[0].strip()[1:])
