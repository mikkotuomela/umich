if (!Detector.webgl) {
	Detector.addGetWebGLMessage();
	document.getElementById('container').innerHTML = "";
}

var SCREEN_WIDTH       = window.innerWidth  - 5;
var SCREEN_HEIGHT      = window.innerHeight - 5;
var SCREEN_WIDTH_HALF  = SCREEN_WIDTH  / 2;
var SCREEN_HEIGHT_HALF = SCREEN_HEIGHT / 2;

var camera, scene, renderer, stats, paper;

var PAPER_SCALE     = 3.0;
var PAPER_WIDTH     = 2159; // US Letter
var PAPER_HEIGHT    = 2794; // Size in mmm
var PAPER_MIN_Z     = -10000;  // Minimum Z distance
var PAPER_MAX_Z     = 0;   // Maximum Z distance
var COLUMNS         = 80;
var ROWS            = 65;
var PAPER_INIT_Z    = -5000;   // Initial Z coordinate

var rotationRate    = 2;     // Scale of mouse rotation
var paperRotationX  = -0.9;  // Initial X rotation
var paperRotationY  = 0.3;   // Initial Y rotation
var mouseWheelSpeed = 8;   // Mouse wheel speed - values < 0.5 are good

// Hard-coded hotspot list
var hotspots = [
	[36,  5, "Food and Drug Administration"],
	[52, 15, "Cannabinoids"],
	[59, 23, "bipolar disorders"],
	[ 1, 24, "anxiety disorder"],
	[28, 25, "autoimmune disease"],
	[45, 28, "Marijuana Policy Project"],
	[64, 29, "AIDS"],
	[35, 31, "chemotherapy"],
	[67, 32, "dronabinol"],
	[33,35, "AIDS"],
	[15, 42, "intraocular pressure"],
	[65, 46, "cannabinoid receptor"],
	[21, 47, "ciliary body"],
	[38, 53, "analgesia"],
	[55, 56, "obsessive compulsive disorder"],
	[14, 57, "Tourette syndrome"],
	[54, 57, "tetrahydrocannabinol"]
];


// Initialize scene
init();
animate();

// Function to initialize everything
function init() {

	camera = new THREE.PerspectiveCamera(75, SCREEN_WIDTH / SCREEN_HEIGHT,
										 1, 30000);
    scene  = new THREE.Scene();
	camera.position.y = 800;
    camera.position.z = 450;

    initPaper(); // Create the paper object
    initStats(); // Create the stats box

    // Create lights
	addSpotLight(5000, -5000, 100, 1, 0xE0E0F0);
	addSpotLight(-4000, 0, -800, 1, 0xFF9090);
	addPointLight(-3000, 1000, -1020, 1, 0xFFF010);
	addPointLight(-5000, 3000, 3700, 1, 0xE0E0FF);
	addPointLight(13000, -3000, 1500, 1, 0xFFE0E0);

	renderer = new THREE.WebGLRenderer();
	renderer.setSize(SCREEN_WIDTH, SCREEN_HEIGHT);

	// Listeners for mouse events
	document.addEventListener('mousemove',      onDocumentMouseMove, false);
	document.addEventListener('DOMMouseScroll', onMouseWheelMove,    false);
	document.addEventListener('mousewheel',     onMouseWheelMove,    false);
	document.body.appendChild(renderer.domElement);

	// Get the container
	document.getElementById('container').appendChild(stats.domElement);
}

// Add a point light to the scene
function addPointLight(x, y, z, intensity, color) {
	var light       = new THREE.PointLight(color);
	light.position  = new THREE.Vector3(x, y, z);
	light.intensity = intensity;
	light.castShadow = true;
	scene.add(light);
}

// Add a point light to the scene
function addSpotLight(x, y, z, intensity, color) {
    var light       = new THREE.DirectionalLight(color);
    light.position  = new THREE.Vector3(x, y, z);
    light.intensity = intensity;
    light.castShadow = true;
    scene.add(light);
}

// Initialize the paper object
function initPaper() {

	// Create geometry
	var paperGeometry = new THREE.PlaneGeometry(PAPER_SCALE * PAPER_WIDTH,
												PAPER_SCALE * PAPER_HEIGHT,
												COLUMNS, ROWS);
	console.log("Geometry created");

	// Create height map
	var data    = new Uint8Array((COLUMNS + 2) * (ROWS + 1) * 3);
	var i = 0;
	for (var y = 0; y <= ROWS; y++) {
		for (var x = 0; x <= COLUMNS; x++) {

			var height = 0; // cumulate this!

			for (var hotspot in hotspots) {
				var dx = x - hotspots[hotspot][0];
				var dy = y - hotspots[hotspot][1];
				var dist = Math.sqrt(Math.pow(dx, 2) + Math.pow(dy, 2));
				if (dist < 3) {
					data[i*3] = 255 - dist * 40;
					data[i*3+1] = 128 - dist * 30;
					data[i*3+2] = 128 - dist * 30;
					height += 200;
				} else {
					data[i*3] = 20 - dist/4;
					data[i*3+1] = 0;
					data[i*3+2] = 0;
					height += 2000 / (dist + 7);
				}
			}

			paperGeometry.vertices[i].position.z = height * 3;
			i++;
		}
	}
	var heatmap = new THREE.DataTexture(data, COLUMNS, ROWS, THREE.RGBFormat);
	heatmap.needsUpdate = true;
	console.log("Height map calculated");

	// Create the mesh object
	var texture       = loadTexture("cannabis.png");
	var paperMaterial = new THREE.MeshLambertMaterial(
		{ color:   0xE0E0E0,
		  shading: THREE.SmoothShading,
		  map:     texture
		});

	paper          = new THREE.Mesh(paperGeometry, paperMaterial);
	paper.position = new THREE.Vector3(0, 0, PAPER_INIT_Z);
	paper.rotation = new THREE.Vector3(paperRotationX, paperRotationY, 0);
	paper.doubleSided   = true;
	paper.castShadow    = true;
	paper.receiveShadow = true;
	paper.vertexColors  = THREE.FaceColors;
	paper.geometry.faces[2300].color.setHex(0xFF0000);

    scene.add(paper);
	console.log("Mesh created and added");
}

// Initialize the Stats bo
function initStats() {
	stats = new Stats();
	stats.domElement.style.position = 'absolute';
	stats.domElement.style.left     = '0px';
	stats.domElement.style.top      = '0px';
}

// Helper function from https://github.com/mrdoob/three.js/issues/458
function loadTexture(url) {
	var image   = new Image();
	var texture = new THREE.Texture(image);
	image.onload = function() {
		texture.needsUpdate = true;
		console.log("texture " + url + " loaded");
	};
	image.src = url;
	return texture;
}

// React to mouse movements - rotate the paper
function onDocumentMouseMove(event) {
	paperRotationX = rotationRate * (event.clientY - SCREEN_HEIGHT_HALF)
		/ SCREEN_HEIGHT_HALF;
	paperRotationY = rotationRate * (event.clientX - SCREEN_WIDTH_HALF)
		/ SCREEN_WIDTH_HALF;
}

// React to mouse wheel movements - zoom the paper
function onMouseWheelMove(event) {
	paper.position.z += mouseWheelSpeed * event.wheelDeltaY;
	if (paper.position.z > PAPER_MAX_Z) paper.position.z = PAPER_MAX_Z;
	if (paper.position.z < PAPER_MIN_Z) paper.position.z = PAPER_MIN_Z;
}

function animate() {
	requestAnimationFrame(animate);
	render();
	stats.update();
}

// Render each frame
function render() {

	// Set paper rotation
	paper.rotation = new THREE.Vector3(paperRotationX, paperRotationY, 0);

	// Render the scene
//	paper.geometry.computeVertexNormals();
	renderer.render(scene, camera);

	// Update status text
//	document.getElementById('status').innerHTML = getStatusText();

}

function getStatusText() {
	return "paperRotationX: " + paperRotationX + "<br />"
		+ "paperRotationY: " + paperRotationY + "<br />"
		+ "paper.position.z: " + paper.position.z;
}
