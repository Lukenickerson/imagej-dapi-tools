# ImageJ DAPI Tools
***ImageJ macro for calculating proximity and overlap***

## Macros

* **dapi-proximity-green-overlap-v3.ijm**

## How to Use

1. Download the macro file (`.ijm`)
1. Optionally modify the macro settings:
	- Open the macro file in an editor
	- Modify the variables that are at the beginning of the file
	- Save the macro
1. In ImageJ (Fiji) go to Plugins > Macros > Run... > select the macro (`.ijm`) file > Open
	- Note that any open images will be closed, and the ROI Manager will be cleared
1. A small dialog will appear. Select Browse to find the image you want to import, and click OK.
1. Watch the processing...
	- It will take a few minutes (the enlarges are slow).
	- Click on the Log window to see what the program is doing.
	- Avoid the ROI Manager or it will likely disturb the program.
1. At the end, the Log will tell you the "Overlap Total", i.e., the number of nucleus-proximity regions that overlap with the green region.
1. The ROI Manager will contain hundreds of ROI, which are hopefully self-explanatory: "green", "nucleus-x", "nucleus-proximity-x", and "prox-green-overlap-x".
1. Save the file as desired.

## Invaluable Resources

* Created with Fiji: https://imagej.net/software/fiji/
* ImageJ macro functions: https://wsr.imagej.net/developer/macro/functions.html

## License

FOSS - See [LICENSE](LICENSE) (and [GNU GPL v3.0 info](https://choosealicense.com/licenses/gpl-3.0/))
