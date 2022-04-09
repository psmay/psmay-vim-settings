#!/usr/bin/env python3

import io
import sys
import csv
import json
import argparse

def csvToJsonArrays(input, output, dumps_parameters, trailing_newline=None, **kwargs):
    csvReader = csv.reader(input)
    rows = [x for x in csvReader]
    output.write(json.dumps(rows, **dumps_parameters))
    if trailing_newline:
        output.write("\n")

def csvToJsonObjects(input, output, dumps_parameters, trailing_newline=None, **kwargs):
    csvReader = csv.DictReader(input)
    rows = [x for x in csvReader]
    output.write(json.dumps(rows, **dumps_parameters))
    if trailing_newline:
        output.write("\n")

def getInput(path):
    if path == None:
        return io.TextIOWrapper(sys.stdin.buffer, newline="", encoding="utf-8-sig")
    else:
        return open(path, newline="", encoding="utf-8-sig")

def getOutput(path):
    if path == None:
        return io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8")
    else:
        return open(path, 'w', newline='', encoding="utf-8")

def getCsvToJsonOperation(name):
    if name == None:
        name = "arrays"

    if name == "arrays":
        return csvToJsonArrays
    elif name == "objects":
        return csvToJsonObjects
    else:
        raise Exception("Unknown operation '%r'" % name)

# Raises an error message if the parameter appears more than once, even if non-conflicting.
#
# If `const` is specified, nargs is 0 (no value is expected after the option) and the const value is stored.
#
# If `const` is not specified, nargs is 1 and the provided value is stored.
#
# This doesn't currently work with default.
class SingularStoreAction(argparse.Action):
    def __init__(self, option_strings, dest, nargs=None, **kwargs):
        if nargs != None:
            raise ValueError("nargs cannot be specified explicitly for this action.")

        if "const" in kwargs:
            nargs = 0
        else:
            nargs = 1

        super().__init__(option_strings, dest, nargs=nargs, **kwargs)

    def __call__(self, parser, namespace, values, option_string=None):
        existing = getattr(namespace, self.dest)

        if existing != None:
            raise argparse.ArgumentError(self, "not allowed multiple times")

        if type(values) is list:
            if len(values) == 0:
                updated = self.const
            elif len(values) != 1:
                raise ValueError("Expected list of 1 element, actual length %r." % len(values))
            else:
                updated = values[0]

        setattr(namespace, self.dest, updated)


#
# JSON Output Formatting Settings Types
#

class CompactOutputFormatting():
    def __init__(self):
        pass

    def dumps_parameters(self):
        return { "separators": (",", ":") }

class IndentedOutputFormatting():
    def __init__(self, indent, count):
        if indent == None or indent == "":
            count = None
        elif not (type(count) is int):
            count = int(count)

        if count < 0:
            raise ValueError("count cannot be negative")
        elif count == 0:
            indent == ""

        self._indent = indent
        self._count = count

    def indent_value(self):
        if self._indent == " ":
            return self._count
        else:
            return self._indent * self._count

    def dumps_parameters(self):
        return { "indent": self.indent_value() }

class IndentedWithSpacesOutputFormatting(IndentedOutputFormatting):
    def __init__(self, count):
        super().__init__(" ", count)

class IndentedWithTabsOutputFormatting(IndentedOutputFormatting):
    def __init__(self, count):
        super().__init__("\t", count)

class IndentedWithTabOutputFormatting(IndentedWithTabsOutputFormatting):
    def __init__(self):
        super().__init__(1)

class IndentedWithCustomOutputFormatting(IndentedOutputFormatting):
    def __init__(self, indent):
        super().__init__(indent, 1)

class SortKeysOutputFormatting():
    def __init__(self, parseableValue):
        pass

    def dumps_parameters(self):
        return { "sort_keys": True }

#
# End JSON Output Formatting Settings Types
#

def filterMapMerge(objects, selector):
    actual = [x for x in objects if x != None]
    selections = [selector(x) for x in actual]
    merged = {k : v for x in selections for k, v in x.items()}
    return merged

def main():
    parser = argparse.ArgumentParser(
        description='Perform processing on CSV data.',
        allow_abbrev=False)
    parser.add_argument('-i', '--input', action=SingularStoreAction)
    parser.add_argument('-o', '--output', action=SingularStoreAction)

    json_output_mode_group = parser.add_mutually_exclusive_group()
    json_output_mode_group.add_argument('--json-output-mode', dest='json_output_mode', action=SingularStoreAction, choices=['arrays','objects'])
    json_output_mode_group.add_argument('--objects', dest='json_output_mode', action=SingularStoreAction, const='objects')
    json_output_mode_group.add_argument('--arrays', dest='json_output_mode', action=SingularStoreAction, const='arrays')

    parser.add_argument('--compact-separators', '--compact', action=SingularStoreAction, const=CompactOutputFormatting())

    indent_group = parser.add_mutually_exclusive_group()
    indent_group.add_argument('--indented-with-spaces', '--indented', dest='indented', metavar='NUMBER OF SPACES', action=SingularStoreAction, type=IndentedWithSpacesOutputFormatting)
    indent_group.add_argument('--indented-with-tab', '--tabbed', dest='indented', action=SingularStoreAction, const=IndentedWithTabOutputFormatting())
    indent_group.add_argument('--indented-with-tabs', metavar='NUMBER OF TABS', dest='indented', action=SingularStoreAction, type=IndentedWithTabsOutputFormatting)
    indent_group.add_argument('--indented-with', dest='indented', action=SingularStoreAction, type=IndentedWithCustomOutputFormatting)

    parser.add_argument('--sort-keys', action=SingularStoreAction, type=SortKeysOutputFormatting)
    parser.add_argument('--trailing-newline', action=argparse.BooleanOptionalAction, default=True)

    parsed = parser.parse_args()

    output_formatting_objects = [ 
        parsed.compact_separators,
        parsed.indented,
        parsed.sort_keys
        ]

    json_dumps_parameters = filterMapMerge(output_formatting_objects, lambda ofo: ofo.dumps_parameters());

    input_path = parsed.input
    if input_path == '-':

        input_path = None

    output_path = parsed.output
    if output_path == '-':
        output_path = None

    json_output_mode = parsed.json_output_mode

    if parsed.trailing_newline == None:
        trailing_newline = parsed.indented != None
    else:
        trailing_newline = parsed.trailing_newline == True

    operation = getCsvToJsonOperation(json_output_mode)
    input = getInput(input_path)
    output = getOutput(output_path)
    operation(input, output, json_dumps_parameters, trailing_newline=trailing_newline)

if __name__ == "__main__":
    main()




