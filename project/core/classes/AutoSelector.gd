extends Node
const MODULE_NAME = "AutoSelector"
var logger = LogWriter.new()

#~~~~~~~~~~#
# Basically what this does is look at all of the nodes that are currently
# loaded and statted by ImageLoader and ImageOptions. It compares each image
# to each other image for 4 different potential deletion reasons. It will
# then select a max of n-1 nodes, starting with the most severe rules
#~~~~~~~~~~#

func autoSelectNodes(nodes: Array):
	# Do no attempt to compare nodes if any had issues loading properties
	if nodes.all(func(node): return !node.imageOptions.initLoadingError and node.imageOptions.fileExists):
		var nodesToMark = []
		var keepLooking: bool = true

		for node in nodes:
			# image size compared to others (height x width)
			if imageIsSmaller(node, nodes):
				node.addPotentialDeletionReason("smaller dimensions")
				if keepLooking:
					nodesToMark.append(node)
					if nodesToMark.size() >= nodes.size() - 1:
						keepLooking = false
		for node in nodes:
			# this image is jpeg and any other is not
			if imageIsJpeg(node, nodes):
				node.addPotentialDeletionReason("jpeg")
				if keepLooking:
					nodesToMark.append(node)
					if nodesToMark.size() >= nodes.size() - 1:
						keepLooking = false
		for node in nodes:
			# any other image of the same type and size is bigger (in KB)
			if fileSizeIsSmaller(node, nodes):
				node.addPotentialDeletionReason("smaller filesize")
				if keepLooking:
					nodesToMark.append(node)
					if nodesToMark.size() >= nodes.size() - 1:
						keepLooking = false
		for node in nodes:
			# any other image is older (re-upload)
			if imageIsNewer(node, nodes):
				node.addPotentialDeletionReason("newer")
				if keepLooking:
					nodesToMark.append(node)
					if nodesToMark.size() >= nodes.size() - 1:
						keepLooking = false
		# at this point, all nodes have been marked against all others
		# and the first n-1 have been selected (maximum)
		for node in nodesToMark:
			node.selectInternal()

func imageIsSmaller(target, nodes: Array):
	# returns true if any other image has more pixels
	var isSmaller: bool = false
	var tx = target.imageOptions.imageWidth
	var ty = target.imageOptions.imageHeight
	var txy = tx*ty
	for node in nodes:
		var nx = node.imageOptions.imageWidth
		var ny = node.imageOptions.imageHeight
		var nxy = nx*ny
		if txy < nxy:
			isSmaller = true
	return isSmaller
	
func imageIsJpeg(target, nodes: Array):
	# returns true if target is a jpeg while others are not
	var isJpeg: bool = false
	var tf = target.imageOptions.imageFiletype
	if not tf in ["jpg", "jpeg"]:
		return false
	for node in nodes:
		var nf = node.imageOptions.imageFiletype
		if not nf in ["jpg", "jpeg"]:
			isJpeg = true
	return isJpeg

func imageIsNewer(target, nodes: Array):
	# returns true if this image is newer than any other match
	# this is prone to failure if the user does not have python installed
	var isNewer: bool = false
	var tt = target.imageOptions.getUnixCreationDate()
	if not tt:
		return false
	for node in nodes:
		var nt = node.imageOptions.getUnixCreationDate()
		if nt and tt > nt:
			isNewer = true
	return isNewer

func fileSizeIsSmaller(target, nodes: Array):
	# returns true if there is another image of the same dimensions and type, but larger file size
	var isSmaller: bool = false
	var tt = target.imageOptions.imageFiletype
	var tx = target.imageOptions.imageWidth
	var ty = target.imageOptions.imageHeight
	var tkb = target.imageOptions.fileSizeKB
	for node in nodes:
		var nx = node.imageOptions.imageWidth
		var ny = node.imageOptions.imageHeight
		var nkb = node.imageOptions.fileSizeKB
		var nt = node.imageOptions.imageFiletype
		if tx == nx and ty == ny and tt == nt and tkb < nkb:
			isSmaller = true
	return isSmaller
