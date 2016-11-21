

### Overview of data preparation, WEKA Segmentation, and data cleanup for thalamostriatal projection detection:
> \*See [ImageJ ](https://github.com/BJHunnicutt/anatomy/tree/master/ImageJ) folder for macros used to set up WEKA segmentation  


1. Choose representative striatal sections (background subtracted, gaussian filtered, masked tiffs) to train:
> * ~4 sections per channel per striatum (more will be used if training requires more examples)
> * representative: browse through whole brain tiff stack, select enough sections to provide the segmentation program with the complete range of diffuse projection (bright/dim), bundled projection (round/stripe), and background information available  

* Open representative striatal sections as masked tiff files in Fiji → create an image stack (Image → Stacks → Images to Stack)

* Load the WEKA Segmentation plugin (Plugins → Segmentation → Trainable WEKA Segmentation).
Initialize the training plugin by running the macro “WEKA_Macro_initialize_training.ijm”
> * creates class names: “Diffuse”, “Bundled”, “Background”
> * selects the filters: Entropy, Membrane Projections, Neighbors, Structure, and Variance
> * selects “homogenization”
> * Do not click anywhere until the macro is finished running or it won’t complete (you can tell it’s finished when the “Bundled” class name is created).

* Train the WEKA software to recognize features of each class.
> * Use the line and shape drawing tools in Fiji to trace examples of each class, adding each example to its respective class in turn.
> * Up to 5 examples of each class per section should be sufficient, although often more will be necessary.
> * When sufficient examples have been selected, press the “Train Classifier” button.
> * The first round of training will take the computer the longest to complete - successive trainings will typically take several minutes less.
> * When the first round of training is complete, check the output, and select more areas to train as needed.

* Once training has been completed sufficiently, save the “data” and “classifier” files.

* Update the appropriate training application macro with the brain and channel file names created above.

* Apply the training data to the whole stack of masked striatum tiffs by running the training application macro (“WEKA_Macro_Final_PC_multibrain.ijm”) overnight (takes ~4hrs per channel). Ensure no other programs are running in the background to help the macro run to completion. The output of this application is the probability mask of each masked striatum tiff and the segmented tiff.

* In MATLAB, select a high and low threshold of each diffuse probability mask using jh_threshold_WEKA.m function.
> * the low threshold should include ALL regions of diffuse projection (will likely include some background that will need to be manually subtracted out later)
> * the high threshold should encompass a more selective, higher probability region of diffuse projections that can be used to determine the real boundaries of the diffuse projection region if manual subtraction is necessary later on

* Apply the selected thresholds to the probability masks using jh_WEKAprobToMask.

* Manually double check (add to/subtract from) the thresholded diffuse projection region using jh_finalProjMaskAdjustments_green.m or jh_finalProjMaskAdjustments_red.m to generate the final diffuse projection probability masks of the striatum.

<!-- https://docs.google.com/document/d/1WE2E9A_CD17WurukYWF_EYuvQU8u9KVvKOVcpn56qic/edit -->
