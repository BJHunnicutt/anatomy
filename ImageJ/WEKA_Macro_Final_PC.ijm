input = "F:\\DATA_7_26_2012\\075080\\str\\maskedTiffs\\green\\";
output = "F:\\DATA_7_26_2012\\075080\\str\\WEKAoutput\\";


list = getFileList(input);
for (i = 0; i < list.length; i++){
        filename = list[i];
        open(input + filename);
        wait(5000);
        setMinAndMax(0, 65535);
	call("ij.ImagePlus.setDefault16bitRange", 16);
	wait(3000);
	run("Advanced Weka Segmentation");
	
	selectWindow("Advanced Weka Segmentation");
	wait(5000);
	call("trainableSegmentation.Weka_Segmentation.createNewClass", "Background");
	wait(3000);
	call("trainableSegmentation.Weka_Segmentation.changeClassName", "0", "Diffuse");
	wait(3000);
	call("trainableSegmentation.Weka_Segmentation.changeClassName", "1", "Bundled");
	wait(3000);
	call("trainableSegmentation.Weka_Segmentation.loadData", "F:\\DATA_7_26_2012\\075080\\str\\TheProcess\\075080_BilateralToNeighbors_data.arff");
	wait(3000);
	call("trainableSegmentation.Weka_Segmentation.loadClassifier", "F:\\DATA_7_26_2012\\075080\\str\\TheProcess\\075080_BilateralToNeighbors_classifier.model");
	wait(3000);
	call("trainableSegmentation.Weka_Segmentation.trainClassifier");
	wait(30000);
	call("trainableSegmentation.Weka_Segmentation.getResult");
	wait(5000);
	saveAs("Tiff", output + "segmented_" + filename);
	wait(5000);
	close();

	selectWindow("Advanced Weka Segmentation");
	call("trainableSegmentation.Weka_Segmentation.getProbability");
	wait(30000);
	selectWindow("Probability maps");
	saveAs("Tiff", output + "probabilities_" + filename);
	wait(5000);
	close();
	
	selectWindow(filename);
	close();
	selectWindow("Advanced Weka Segmentation");
	close();
	run("Reset...", "reset=[Undo Buffer]");
}