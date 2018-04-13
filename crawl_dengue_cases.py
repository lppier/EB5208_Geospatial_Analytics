import pandas as pd
import requests
import os

dengue_case = {
    'central': 'https://geo.data.gov.sg/denguecase-central-area/{year:04d}/{month:02d}/{day:02d}/kml/denguecase-central-area.kml',
    'northeast': 'https://geo.data.gov.sg/denguecase-northeast-area/{year:04d}/{month:02d}/{day:02d}/kml/denguecase-northeast-area.kml',
    'northwest': 'https://geo.data.gov.sg/denguecase-northwest-area/{year:04d}/{month:02d}/{day:02d}/kml/denguecase-northwest-area.kml',
    'southeast': 'https://geo.data.gov.sg/denguecase-southeast-area/{year:04d}/{month:02d}/{day:02d}/kml/denguecase-southeast-area.kml',
    'southwest': 'https://geo.data.gov.sg/denguecase-southwest-area/{year:04d}/{month:02d}/{day:02d}/kml/denguecase-southwest-area.kml'
}


if __name__ == "__main__":
    dt_range = pd.date_range(start='2018-04-01', end='2018-04-13')
    for date in dt_range:
        print("checking dengue cases on {}".format(date))
        for location, url in dengue_case.items():
            url = url.format(year=date.year, month=date.month, day=date.day)
            response = requests.get(url, stream=True)
            if response.ok:
                print("downloading dengue case at {location} area from {url}".format(location=location, url=url))
                directory = "Data/{year:04d}-{month:02d}-{day:02d}/".format(year=date.year, month=date.month,
                                                                            day=date.day)
                if not os.path.exists(directory):
                    os.makedirs(directory)

                filename = "{directory}/denguecase-{location}-area.kml".format(directory=directory, location=location)
                with open(filename, "wb") as handle:
                    handle.write(response.content)
