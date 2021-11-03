
let numTargets = 5
const TARGET_RADIUS = 40
const LARGE_SIDE = 400
const SMALL_SIDE = 200
const MAX_TRIAL = 1000

def toPx num
	return num+"px"

def toNum pxNum
	return Number(pxNum.slice(0, pxNum.length - 2))

def getRandomTargetPosition h, w, i
	const directionAngle = Math.random! * 2 * Math.PI
	return 
		position:
			x: toPx(Math.random! * (w - TARGET_RADIUS))
			y: toPx(Math.random! * (h - TARGET_RADIUS))
		direction:
			x: Math.cos(directionAngle)
			y: Math.sin(directionAngle)
		distractor: i !== 1

def distance p1, p2
	return Math.sqrt((toNum(p1.x) - toNum(p2.x)) ** 2 + (toNum(p1.y) - toNum(p2.y)) ** 2)

def collidesWith candidate
	let func = do(target) 
		return (distance(target.position, candidate.position) <= TARGET_RADIUS)
	return func

def noCollision candidate, targets
	return !targets.some(collidesWith(candidate))

def initTargets h, w
	let targets = []
	for i in [0 ... numTargets]
		let trial = 0
		while trial < MAX_TRIAL
			let target_candidate = getRandomTargetPosition(h, w, i)
			if noCollision(target_candidate, targets)
				targets.push(target_candidate)
				break
			trial++ 
	return targets

def updatePxString init, modif
	return toPx(toNum(init) + modif)

def newDirection direction, v
	return
		x: direction.x * v.x
		y: direction.y * v.y

def targetsCollision tpos1, tpos2
	return (distance(tpos1, tpos2) <= TARGET_RADIUS)	

def magnitude v
	return Math.sqrt(v.x * v.x + v.y * v.y)

def normalize2DVector v
	const mag = magnitude(v)
	return
		x: v.x / mag
		y: v.y / mag

def collisionNewDirection dirInit, dir

	const normalVector = normalize2DVector(
		x: dir.x - dirInit.x
		y: dir.y - dirInit.y
	)
	const tangential =
		x: -normalVector.y
		y: normalVector.x

	return normalize2DVector(
		x: tangential.x + normalVector.x
		y: tangential.y + normalVector.y 
	)

def updateTargets targets, snooker_width, snooker_height
	const currentNextTargets =
		targets.map(do(t) return 
			position:
				x: updatePxString(t.position.x, t.direction.x)
				y: updatePxString(t.position.y, t.direction.y)
			direction:
				x: t.direction.x
				y: t.direction.y
		)
	
	for t in targets
		t.changed = false

	for t1, index in currentNextTargets
		# target - target collision
		for t2, index2 in currentNextTargets
			if index2 === index
				continue
			if targetsCollision(t1.position, t2.position)
				if !targets[index].changed
					targets[index].changed = true
					targets[index].direction = collisionNewDirection(t1.direction, t2.direction)
				if !targets[index2].changed
					targets[index2].changed = true
					targets[index2].direction = collisionNewDirection(t2.direction, t1.direction)

		# border collisions
		if toNum(targets[index].position.x) + TARGET_RADIUS > snooker_width
			targets[index].direction = newDirection(t1.direction, {x: -1, y: 1})
		if toNum(targets[index].position.x) < 0
			targets[index].direction = newDirection(t1.direction, {x: -1, y: 1})
		if toNum(targets[index].position.y) < 0
			targets[index].direction = newDirection(t1.direction, {x: 1, y: -1})
		if toNum(targets[index].position.y) + TARGET_RADIUS > snooker_height
			targets[index].direction = newDirection(t1.direction, {x: 1, y: -1})

	for t in targets
		t.position =
			x: updatePxString(t.position.x, t.direction.x)
			y: updatePxString(t.position.y, t.direction.y)

def colorTarget t
	return t.distractor ? "red4" : "yellow2"

tag Snooker
	prop vertical = true
	prop height = this.vertical ? LARGE_SIDE : SMALL_SIDE
	prop width = this.vertical ? SMALL_SIDE : LARGE_SIDE
	prop targets = initTargets(height, width)
	prop startTime = Date.now!

	def render
		updateTargets(targets, width, height)
		<self[h:{toPx(height)} w:{toPx(width)} bg:white bd:1px solid blue pos:relative]>
			for t in targets
				<div.target [position:absolute t:{t.position.y} l:{t.position.x} w:{toPx(TARGET_RADIUS)} h:{toPx(TARGET_RADIUS)} bgc:{colorTarget(t)} rd:{toPx(TARGET_RADIUS)}]>

export tag SplitAttentionPage
	<self[d:flex fld:row]>
		<Snooker autorender=10fps>
		<Snooker autorender=30fps>
