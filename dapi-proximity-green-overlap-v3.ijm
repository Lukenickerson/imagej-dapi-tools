// ----- Can modify these if desired -----
proximityMicrons = 1.5;
blueContrastMin = 3;
blueContrastMax = 249;
greenContrastMin = 202;
greenContrastMax = 1767;
redContrastMin = 49;
redContrastMax = 217;
greenRoiName = "green";
redRoiName = "red";
imageName = "1785a_1_1";
filePath = "T:/Dev/imagej/";
fileExtension = "lif";
greenOverlapRoiNamePrefix = "prox-green-overlap-";
redOverlapRoiNamePrefix = "prox-red-overlap-";

// ----- Beware modifying below here -----
groupsList = "green,nuclei,proximity,greenprox,red,redprox";
greenGroup = 1;
nucleiGroup = 2;
proximityGroup = 3;
greenProxGroup = 4;
redGroup = 5;
redProxGroup = 6;
fileName = imageName + "." + fileExtension;
defaultFullFilePath = filePath + fileName;
blueImageId = 1;
greenImageId = 2;
redImageId = 3;

// ----- The functions -----

function selectNucleiImage() {
	selectImage(blueImageId);
}

function setContrasts() {
	selectNucleiImage();
	setMinAndMax(blueContrastMin, blueContrastMax);
	selectImage(greenImageId);
	setMinAndMax(greenContrastMin, greenContrastMax);
	selectImage(redImageId);
	setMinAndMax(redContrastMin, redContrastMax);
	write("Contrasts set");
}

function tracePlaque() {
	selectNucleiImage();
	waitForUser("Trace Plaque, then hit OK");
	run("Clear Outside");	
}

function selectLast() {
	roiManager("Select", roiManager("count") - 1);
}

function rename(name) {
	Roi.setName(name);
	roiManager("Rename", name);
}

function setThreshold(text) {
	// Dialog.createNonBlocking("Threshold");
	// Dialog.addMessage("Set the threshold" + text);
	// Dialog.addCheckbox("Auto Threshold", true);
	// Dialog.addMessage("If unchecked, please set the threshold yourself\nbefore continuing by clicking OK.");
	// Dialog.show();
	setAutoThreshold("Default dark no-reset");
	setOption("BlackBackground", true);
	waitForUser("Set the threshold" + text + ", then hit OK to continue.");
	run("Convert to Mask");
	// if (Dialog.getCheckbox()) run("Convert to Mask");
}

function calcImageMaskSelection(imageIndex, roiName, group) {
	selectImage(imageIndex);
	setThreshold(" for group " + roiName);
	run("Create Selection");
	roiManager("Add");
	selectLast();
	rename(roiName);
	Roi.setGroup(group);
	roiManager("deselect");
}

function calcNuclei(groupIndex) {
	startIndex = roiManager("count");
	selectNucleiImage();
	setThreshold(" for nuclei");
	run("Analyze Particles...", "size=2.00-Infinity display clear summarize overlay add composite");
	count = roiManager("count") - startIndex;
	write("Found " + count + " nuclei (blue), index: " + startIndex);

	// Set group and rename
	RoiManager.selectGroup(0);
	RoiManager.setGroup(groupIndex);
	roiManager("deselect");
	for (i = 0; i < count; i++) {
		roiManager("Select", i + startIndex);
		n = i + 1;
		rename("nucleus-" + n);
	}
}

function getNucleiStartIndex() {
	return RoiManager.getIndex("nucleus-1");
}

function getNucleiCount() {
	RoiManager.selectGroup(nucleiGroup);
	nc = RoiManager.selected;
	roiManager("deselect");
	return nc;
}

function calcProximity(groupIndex, enlargeMicrons) {
	selectNucleiImage();
	startIndex = getNucleiStartIndex();
	count = getNucleiCount();
	write("Enlarging " + count + "...");
	for (i = 0; i < count; i++) {
		roiManager("Select", i + startIndex);
		n = i + 1;
		// write("Working on " + i + "/" + count);

		run("Enlarge...", "enlarge=" + enlargeMicrons);
		roiManager("Add");
		selectLast();
		rename("nucleus-proximity-" + n);
		Roi.setGroup(groupIndex);
	}
	write("Enlarging done");
}

function getProximityNucleiStartIndex() {
	return RoiManager.getIndex("nucleus-proximity-1");
}

function deleteNucleiSelections() {
	write("Deleting " + count + "...");
	for (i = 0; i < count; i++) {
		roiManager("Select", startIndex);
		roiManager("Delete");
	}
	write("Deleting done");
}

function calcOverlap(i, startIndex, overlapRoiIndex, namePrefix, overlapGroup) {
	overlap = 0;
	roiManager("Select", newArray(i + startIndex, overlapRoiIndex));
	name1 = RoiManager.getName(i + startIndex);
	name2 = RoiManager.getName(overlapRoiIndex);
	n = i + 1;

	roiManager("AND");
	// At this point it is possible there is no overlap, which
	// will make there be no selection. Detect this:
	selType = selectionType();	
	explain = "";
	if (selType == -1) {
		explain = "skip";
		overlap = 0;
	} else {
		roiManager("Add");
		selectLast();
		newName = namePrefix + n;
		explain = "added " + newName;
		rename(newName);
		Roi.setGroup(overlapGroup);
		overlap = 1;
	}
	write("      (" + n + ") " + name1 + " AND " + name2 + " --> " + explain);
	return overlap;
}

function calcOverlaps() {
	greenRoiIndex = RoiManager.getIndex(greenRoiName);
	redRoiIndex = RoiManager.getIndex(redRoiName);
	startIndex = getProximityNucleiStartIndex(); // This assumes these are all in order
	count = getNucleiCount(); // assume prox-nuclei has same count
	write("Finding overlaps " + count + "...");
	greenOverlapCount = 0;
	redOverlapCount = 0;
	bothOverlapCount = 0;
	for (i = 0; i < count; i++) {
		greenOverlap = calcOverlap(i, startIndex, greenRoiIndex, greenOverlapRoiNamePrefix, greenGroup);
		redOverlap = calcOverlap(i, startIndex, redRoiIndex, redOverlapRoiNamePrefix, redGroup);
		greenOverlapCount += greenOverlap;
		redOverlapCount += redOverlap;
		if (redOverlap > 0 && greenOverlap > 0) bothOverlapCount += 1;
	}
	write("Overlap done");
	results = "Overlaps with green: " + greenOverlapCount + "\nOverlaps with red: " + redOverlapCount + "\nOverlaps with both green and red: " + bothOverlapCount;
	// write("Overlaps with green: " + greenOverlapCount);
	// write("Overlaps with red: " + redOverlapCount);
	// write("Overlaps with both green and red: " + bothOverlapCount);
	write(results);
	Dialog.createNonBlocking("Results");
	Dialog.addMessage(results);
}

function process() {
	// ----- Setup
	run("Close All");
	Dialog.create("DAPI Proximity Overlap");
	Dialog.addFile("Image File", "");
	Dialog.addNumber("Proximity", proximityMicrons, 2, 5, "microns");
	Dialog.show();
	fullFilePath = Dialog.getString();
	proximityMicrons = Dialog.getNumber();
	if (fullFilePath == "") fullFilePath = defaultFullFilePath;
	write(" ");
	write("Opening " + fullFilePath);
	run("Bio-Formats", "open=" + fullFilePath + " autoscale color_mode=Default rois_import=[ROI manager] split_channels view=Hyperstack stack_order=XYCZT");
	setContrasts();
	// in case there are some ROI left from previous work
	roiManager("reset");
	Roi.setGroupNames(groupsList);
	write("Groups: " + Roi.getGroupNames);

	// ----- Calculations
	tracePlaque();
	calcNuclei(nucleiGroup);
	// For some reason calcNuclei wipes out the ROI, so we need to
	// do all the selection calculations afterwards
	calcImageMaskSelection(greenImageId, greenRoiName, greenGroup);
	calcImageMaskSelection(redImageId, redRoiName, redGroup);
	calcProximity(proximityGroup, proximityMicrons);
	// deleteNucleiSelections();
	calcOverlaps();
}

process();
