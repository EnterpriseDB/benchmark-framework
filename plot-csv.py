import argparse
import dateutil.parser
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates

from pathlib import Path

def read_command_line():
    """Read the command line arguments.
    Returns:
        ArgumentParser: The parsed arguments object
    """
    parser = argparse.ArgumentParser(
        description='Plot a graph from a CSV file.')

    parser.add_argument('input',
                        help='the CSV file to plot')

    parser.add_argument('--style', '-s',
                        default='line',
                        choices=['line', 'area'],
                        help='type of chart to create')

    parser.add_argument('--width',
                        default=10,
                        type=int,
                        help='plot width in inches (default: 10)')

    parser.add_argument('--height',
                        default=6,
                        type=int,
                        help='plot height in inches (default: 6)')

    parser.add_argument('--title', '-t',
                        help='plot title (defaults to the input filename '
                             'without extension)')

    parser.add_argument('--percent', '-p',
                        default=False, action='store_true',
                        help='scale to 100%%, rather than printing absolute values')

    parser.add_argument('--colormap', '-c',
                        default='plasma',
                        help='matplotlib colormap to use when rendering '
                             '(default: plasma)')

    parser.add_argument('--xlabel',
                        help='label to display on the X axis')

    parser.add_argument('--ylabel',
                        help='label to display on the Y axis')

    try:
        args = parser.parse_args()
    except:
        exit(1)

    return args

args = read_command_line()

# Create the dataframe
df = pd.read_csv(args.input, index_col=0, parse_dates=[0], date_parser=dateutil.parser.isoparse)

title = Path(args.input).stem
if args.title is not None:
    title = args.title

if args.percent:
    df = df.apply(lambda x: x*100/sum(x), axis=1)

fig, ax = plt.subplots(figsize=(args.width, args.height),
                       tight_layout=True)

if args.style == 'line':
    df.plot.line(title=title, colormap=args.colormap, ax=ax)
elif args.style == 'area':
    df.plot.area(title=title, colormap=args.colormap, ax=ax)

# Date formatting
ax.xaxis.set_major_formatter(mdates.DateFormatter('%Y-%m-%d\n%H:%M:%S'))

# Titles
ax.xaxis.set_label_text(args.xlabel)
ax.yaxis.set_label_text(args.ylabel)

# Figure out the output file name
output = Path(args.input).with_suffix('.png')
plt.savefig(output)
print('Wrote {}'.format(output))
