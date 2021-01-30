import data.EWBIKSaver;
import ewbik.processing.singlePrecision.*;
import ewbik.processing.singlePrecision.sceneGraph.*;
import math.floatV.MathUtils;

import java.util.ArrayList;
import java.io.File;
String delim = File.separator;

float zoomScalar = 7f/height;	

UI ui; 

Armature humanArmature;
Bone  rootBone, 
c1, c3, c5,
l_collar_bone,	r_collar_bone,
l_upper_arm,		r_upper_arm,
l_lower_arm,		r_lower_arm,
l_hand,					r_hand,
neck_1,
neck_2,
head;


Axes worldAxes;
ArrayList<IKPin> pins = new ArrayList<IKPin>();

Axes cubeAxes;
public static IKPin activePin; 

public void setup() {
	  size(1200, 900, P3D);
	  ui = new UI(true); //ignore this line, it's just for user Interace stuff. 
		
		worldAxes = new Axes(); 
		cubeAxes = new Axes(); 
		cubeAxes.setParent(worldAxes);
		humanArmature = new Armature( "example");
		humanArmature.localAxes().setParent(worldAxes);
		worldAxes.translateTo(new PVector(0f, 50f, 0));
		humanArmature.localAxes().rotateAboutZ(PI, true);

		//specify that we want the solver to run 15 iteration whenever we call it.
		humanArmature.setDefaultIterations(15);
		//specify the maximum amount any bone is allowed to rotate per iteration (slower convergence, nicer results) 
		humanArmature.setDefaultDampening(0.25f);
		//1 = specify that the armature should avoid wobbly solutions (more reliable) 
		//0 = allow wobbly solutions  (faster, and usually sufficient). 
		humanArmature.setDefaultStabilizingPassCount(1);
		//benchmark performance
		humanArmature.setPerformanceMonitor(true);
		
		//Add some bones to the armature
		initializeBones(); 		
		setBoneConstraints();
		//add the pins/targets to an array so we can cycle through them easily with keyboad input. 
		 updatePinList();		 		 
		 
		humanArmature.updateArmatureSegments();
		humanArmature.IKSolver(rootBone, 0.5f, 20, 1);

		//Tell the Bone class that all bones should draw their kusudamas.
		Bone.setDrawKusudamas(true);
		//Enable fancy multipass shading for translucent kusudamas. 
		Kusudama.enableMultiPass(true);

	}

	public void draw() {		
		if(mousePressed) {
			activePin.translateTo(new PVector(ui.mouse.x, ui.mouse.y, activePin.getLocation_().z));	
			humanArmature.IKSolver(rootBone);
		}else {
			worldAxes.rotateAboutY(PI/500f, true);
		}    
		zoomScalar = 200f/height;
		String additionalInstructions =  "\n HIT THE S KEY TO SAVE THE CURRENT ARMATURE CONFIGURATION.";
		ui.drawScene(zoomScalar, 10f, null, humanArmature, additionalInstructions, activePin, cubeAxes, false);
	}


	public void initializeBones() {
		rootBone = humanArmature.getRootBone();
		rootBone.setBoneHeight(1f);
		rootBone.localAxes().markDirty();
		rootBone.localAxes().updateGlobal();
		c1 = new Bone(rootBone, "c1", 6f);		
		c3 = new Bone(c1, "c3", 6f);		
		c5 = new Bone(c3, "c5", 6f);
		neck_1 = new Bone(c5, "neck 1", 6f);
		neck_2 = new Bone(neck_1, "neck 2", 6f); 
		head = new Bone(neck_2, "head", 6f);

		r_collar_bone = new Bone(c5, "right collar bone", 6f); 
		r_collar_bone.rotAboutFrameZ(MathUtils.toRadians(-50f));		

		l_collar_bone = new Bone(c5, "left collar bone", 6f); 
		l_collar_bone.rotAboutFrameZ(MathUtils.toRadians(50f));		

		head.enablePin();
		head.getIKPin().setPinWeight(5f);
		head.getIKPin().setTargetPriorities(5f, 5f, 5f);
		rootBone.enablePin();

		worldAxes.rotateAboutX(MathUtils.toRadians(-10f), true);
	}

	public void setBoneConstraints() {    
		Kusudama r_collar_joint = new Kusudama(r_collar_bone);
		r_collar_joint.addLimitConeAtIndex(0, new PVector(1.0f, 0.4f, 0f), 0.7f);
		r_collar_joint.setAxialLimits(-0.3f, 1f);
		r_collar_joint.optimizeLimitingAxes();
		r_collar_joint.setPainfullness(0.1f);

		Kusudama l_collar_joint = new Kusudama(l_collar_bone);
		l_collar_joint.addLimitConeAtIndex(0, new PVector(-1.0f, 0.4f, 0f), 0.7f);
		l_collar_joint.setAxialLimits(-0.7f, 1f);
		l_collar_joint.optimizeLimitingAxes();
		l_collar_joint.setPainfullness(0.1f);

		Kusudama neck1j = new Kusudama(neck_1);
		neck1j.addLimitConeAtIndex(0, new PVector(0f,1f,0f), 0.01f);
		neck1j.setAxialLimits(0.001f, 0.002f);
		neck1j.optimizeLimitingAxes();		

		Kusudama c1j = new Kusudama(c1);
		c1j.addLimitConeAtIndex(0, new PVector(0f,1f,0f), MathUtils.toRadians(10f));
		c1j.setAxialLimits(-MathUtils.toRadians(20f), MathUtils.toRadians(20f));
		c1j.optimizeLimitingAxes();		

		Kusudama c3j = new Kusudama(c3);
		c3j.addLimitConeAtIndex(0, new PVector(0f,1f,0f), MathUtils.toRadians(10f));
		c3j.setAxialLimits(-MathUtils.toRadians(20f), MathUtils.toRadians(20f));
		c3j.optimizeLimitingAxes();		

		Kusudama c5j = new Kusudama(c5);
		c5j.addLimitConeAtIndex(0, new PVector(0f,1f,0f), MathUtils.toRadians(10f));
		c5j.setAxialLimits(-MathUtils.toRadians(20f), MathUtils.toRadians(20f));
		c5j.optimizeLimitingAxes();

		Kusudama neck2j = new Kusudama(neck_2);
		neck2j.addLimitConeAtIndex(0, new PVector(0f,1f,0f), MathUtils.toRadians(10f));
		neck2j.setAxialLimits(-MathUtils.toRadians(20f), MathUtils.toRadians(20f));
		neck2j.optimizeLimitingAxes();

		Kusudama headj = new Kusudama(head);
		headj.addLimitConeAtIndex(0, new PVector(0f,1f,0f), MathUtils.toRadians(40f));
		headj.setAxialLimits(-MathUtils.toRadians(20f), MathUtils.toRadians(20f));
		headj.optimizeLimitingAxes();
	}


	public void mouseWheel(MouseEvent event) {
		float e = event.getCount();
		Axes axes = (Axes) activePin.getAxes(); 
		if(event.isShiftDown()) {
			axes.rotateAboutZ(e/TAU, true);
		}else if (event.isControlDown()) {
			axes.rotateAboutX(e/TAU, true);
		}  else {
			axes.rotateAboutY(e/TAU, true);
		}
		humanArmature.IKSolver(rootBone);  
	}

	public void keyPressed() {
		if (key == CODED) {
			if (keyCode == DOWN) {      
				int currentPinIndex =(pins.indexOf(activePin) + 1) % pins.size();
				activePin  = pins.get(currentPinIndex);
			} else if (keyCode == UP) {
				int idx = pins.indexOf(activePin);
				int currentPinIndex =  (pins.size()-1) -(((pins.size()-1) - (idx - 1)) % pins.size());
				activePin  = pins.get(currentPinIndex);
			} 
		} else if(key == 's') {
			println("Saving");
			EWBIKSaver newSaver = new EWBIKSaver();
			newSaver.saveArmature(humanArmature, "Chain.arm");			
		}
	}

	public void updatePinList() {
		pins.clear();
		recursivelyAddToPinnedList(pins, humanArmature.getRootBone());
		if(pins .size() > 0) {
			activePin = pins.get(pins.size()-1);
		} 
	}

	public void recursivelyAddToPinnedList(ArrayList<IKPin> pins, Bone descendedFrom) {
		ArrayList<Bone> pinnedChildren = (ArrayList<Bone>) descendedFrom.getMostImmediatelyPinnedDescendants(); 
		for(Bone b : pinnedChildren) {
			pins.add((IKPin)b.getIKPin());
			b.getIKPin().getAxes().setParent(worldAxes);
		}
		for(Bone b : pinnedChildren) {
			ArrayList<Bone> children = b.getChildren(); 
			for(Bone b2 : children) {
				recursivelyAddToPinnedList(pins, b2);
			}
		}
	}
