import xml.etree.ElementTree as et
import pandas as pd
import os

dengue_case = {
    'central': 'https://geo.data.gov.sg/denguecase-central-area/{year:04d}/{month:02d}/{day:02d}/kml/denguecase-central-area.kml',
    'northeast': 'https://geo.data.gov.sg/denguecase-northeast-area/{year:04d}/{month:02d}/{day:02d}/kml/denguecase-northeast-area.kml',
    'northwest': 'https://geo.data.gov.sg/denguecase-northwest-area/{year:04d}/{month:02d}/{day:02d}/kml/denguecase-northwest-area.kml',
    'southeast': 'https://geo.data.gov.sg/denguecase-southeast-area/{year:04d}/{month:02d}/{day:02d}/kml/denguecase-southeast-area.kml',
    'southwest': 'https://geo.data.gov.sg/denguecase-southwest-area/{year:04d}/{month:02d}/{day:02d}/kml/denguecase-southwest-area.kml'
}


def convert_polygon_to_point(polygon):
    min_lat = 10000.0
    max_lat = 0.0
    min_long = 10000.0
    max_long = 0.0

    for point in polygon:
        min_lat = min(min_lat, point[1])
        min_long = min(min_long, point[0])
        max_lat = max(max_lat, point[1])
        max_long = max(max_long, point[0])

    return {'Latitude': min_lat + (max_lat - min_lat) / 2, 'Longitude': min_long + (max_long - min_long) / 2}


def parse_kml(kml, date):
    kml_tree = et.parse(kml)
    root = kml_tree.getroot()

    data = []

    for element in root.iter("{http://www.opengis.net/kml/2.2}Placemark"):
        name = element.find("{http://www.opengis.net/kml/2.2}name")
        item = {'NAME': name.text, 'Date': date.strftime("%m/%d/%Y")}
        simple_data = element.iter("{http://www.opengis.net/kml/2.2}SimpleData")
        for child in simple_data:
            item[child.attrib['name']] = child.text
        coordinates = element.iter("{http://www.opengis.net/kml/2.2}coordinates")

        location = ""
        for child in coordinates:
            location = child.text.split(" ")
        new_coordinates = []
        for coordinate in location:
            new_coordinates.append(coordinate.split(","))
        polygon = []
        for coordinate in new_coordinates:
            loc = []
            for number in coordinate:
                loc.append(float(number))
            polygon.append(loc)
        location = convert_polygon_to_point(polygon)
        item = {**item, **location}

        data.append(item)

    return data


if __name__ == "__main__":
    dataframe = pd.DataFrame()

    dt_range = pd.date_range(start='2018-03-01', end='2018-04-13')
    for date in dt_range:
        print("checking dengue cases on {}".format(date))
        for location, url in dengue_case.items():
            try:
                directory = "Data/{year:04d}-{month:02d}-{day:02d}/".format(year=date.year, month=date.month,
                                                                            day=date.day)
                filename = "{directory}/denguecase-{location}-area.kml".format(directory=directory, location=location)
                sub_dataframe = parse_kml(filename, date)
                sub_dataframe = pd.DataFrame(sub_dataframe)
                dataframe = dataframe.append(sub_dataframe)
            except FileNotFoundError as e:
                print("No File on date: {}".format(date.strftime("%m/%d/%Y")))

    dataframe.to_csv("Converted_Data/denguecases-area.csv", index=False)
