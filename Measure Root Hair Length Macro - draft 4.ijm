//Prompting user to open file they want to use 
path = File.openDialog("Select a File");

//Open file
open(path);

//Retrieve file directory and file name
dir = File.getParent(path);
name = File.getName(path);

//Remove file extension
dotIndex = indexOf(name, ".");
title = substring(name, 0, dotIndex); 


//Clear any previous data table 
run("Clear Results"); 
//Remove any current selections in image
//NOTE: Left-over selections from before running macro cause unpredicted behavior
run("Select None");



//-------------------------------------------Data quality control check-----------------------------------------------

//Get the unit,pixel width, and height of the image
getPixelSize(unit, pixelWidth, pixelHeight);

//Check for # of channels, slices, and frames. If there are more than 1 slices, frames, and/or channels, then it will inform user of error.
getDimensions(width, height, channels, slices, frames)
if (channels != 1 || slices != 1 || frames != 1) {
	exit("ERROR: frames, channels, and slices must be equal to 1 for this to continue.");
}

//Inform user of the error if width and height of pixel are not equal to each other
if (pixelWidth != pixelHeight) {
	exit("ERROR:The pixel width and pixel height are not equal to each other.");	
}


//Inform user that there is no dimension because the unit in pixel
if (unit== "pixels") {
	showMessage(" No demension!", "The unit is in pixel; therefore, the image doesn't have dimension.");
	//Force user to change the pixel dimension 
	changeUnit= 0;
}

//-----------------------------------------Verify pixel dimesnions before measuring---------------------------------------

//Display the current pixel dimension to user. User gets to decide whether to keep the current unit or change it.
else {
	changeUnit = getBoolean("The current pixel dimension is: " + pixelWidth + " " + unit + ". Do you wish to keep this unit?");
}

//Help user change pixel dimensions if "No" is clicked on 
if (changeUnit== 0) {
	
	//Getting desired unit of dimension
	unit = getString("Enter pixel unit of measure (e.g. cm, um, nm, in).", unit);
	
	//Getting desired dimension number 
	pixelWidth = getNumber("Enter desired pixel dimensions.", pixelWidth); 
		
	// Changing the unit and pixel dimension
	run("Properties...", "channels=1 slices=1 frames=1 unit=" + unit + "  pixel_width=" + pixelWidth + " pixel_height=" + pixelWidth + " voxel_depth=1");
}


//-------------------------Settings for tracing root hair------------------------


//Set line width that is used to make measured root hairs
lineWidth = getNumber("How wide do you want to make the line that marks measured root hairs?", 3); 
run("Line Width...", "line=" + lineWidth);

//Choosing tool for tracing root hair 
setTool("polyline");

//Set initial hair masurement to 0 so program enters while loop
HairLength = 0;

// Start row counter at position 1
RowNumber= 0;

//Measuring each root hair until user is done
while (HairLength < 99999) {

	//Stop macro until user is finished with tracing root hair
	waitForUser("Trace next root hair", "Click 'OK' when finished tracing root hair.");

//------------------Check to make sure a measurement has been made----------------------------------------------------
	//If the user returns a non-existent selection, then prompt user and do not save selection

	//Measuring width and height of the whole image 
	getDimensions(imageWidth, imageHeight, channels, slices, frames);
	
	//Tell where and how big the selection is 
	getSelectionBounds(x, y, width, height);
	
	//Inform user that no selection has been made
	//NOTE: getSelectionBound returns (0,0, imageWidth, imageHeight) if no selection has been made 
	if(x == 0 && y == 0 && width== imageWidth && height== imageHeight) {
		showMessage("No selection found!", "Current measurement was not recorded.");
	}

//-------------------Record measurement if desired, other wise erase or exit------------------------------------
	else {

		//Measure the root hair's length 
		run("Measure");
		
		//Retrieving the most recent hair measurement
		HairLength =getResult("Length",RowNumber);
		
		// Ask user to enter 0 if desire to erase measurement or enter >99999 if finished 
		HairLength = getNumber("Enter 0 to delete measurement. Enter any number greater than 99999 if you are finished. Current measurement:", HairLength); 

		//Carry out what the user wants to do 
		//NOTE: If user enters 0, delete current measurement
		if( HairLength==0) {
			IJ.deleteRows(RowNumber, RowNumber);
		}
		//If the length of hair is between 0 and 99999, then record the measurement and move the row counter down 1
		if (HairLength > 0 && HairLength <= 99999) {
			RowNumber= RowNumber+1; 

			//Draw a line under selection to mark root hairs that have been measured
			run("Draw");
		}
	}
	//Clear all previous selection before measuring next hair root
	run("Select None");
	
	//Delete last measurement because it is not a real measurement 
	IJ.deleteRows(RowNumber, RowNumber);
	
}

//Remove all selections when finished
run("Select None");

// Save recorded measurements into Excel 
	//Quality Contro- if results are empty then it doesn't save into Excel
	if (nResults==0) {
		showMessage("Empty Results Table"," No measurements are found in Results Table.");
	}
	else {
		pathExcel = dir + title + "-measurements.xls";
		saveAs("Results", pathExcel);
	}

