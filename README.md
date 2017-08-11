# cancer-segmentation
A set of segmentation software borrowed from academic sources (citations are within code); some specifically designed for segmenting cancerous regions from microscopic tissue images.


Segmentation_methods:
Contains all segmentation methods researched. 
	-Bipartite_script:
	Contains all directories needed for script to work as well as three functions...
		-createpatches.m:
		Script used to split image into patches, segment patches and sew back segmented patches into orgininal image size.
		-demo_SAS_BSDS.m: 
		Segmentation algorithm used in createpatches.m. Need to add Bipartite_script directory to path.
		-fullimageseg.m:
		Used to segemnt full images which is needed to compare against patch based method segmentation.
				
-Contour_detection:
	-BSR_code:
		use example.m located in 'grouping' directory.
		
-Original_methods: 
	Contains original, untainted, segmentation scripts.
		
-RegionScalableEnergy, Bipartite_code.zip, and Contour_detection_code.zip: 
		Original scripts. The original script for chan vese is located on the server. I did not get to implement the code in RegionScalableEnergy. 

-sfm_local_chanvese:
	-chanveseresults:
		Two images of chanveseresults.. Chanvese method requires mask image to approximate segmentation region.

-Main function is sfm_local_chanvese.m. 
		
