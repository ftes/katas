interface Frame {
    val rolls: List<Int>
    var next: Frame?
    fun score(): Int = rolls.sum()
    fun firstRoll(): Int = rolls[0]
    fun firstTwoRolls(): List<Int> = rolls.slice(0..1)
}

data class NormalFrame(override val rolls: List<Int>) : Frame {
    override var next: Frame? = null
}

data class SpareFrame(override val rolls: List<Int>) : Frame {
    override var next: Frame? = null

    override fun score(): Int {
        return rolls.sum() + (next?.firstRoll() ?: 0)
    }
}

data class StrikeFrame(override val rolls: List<Int> = listOf(10)) : Frame {
    override var next: Frame? = null
    override fun score(): Int {
        return rolls.sum() + (next?.firstTwoRolls()?.sum() ?: 0)
    }

    override fun firstTwoRolls(): List<Int> {
        return listOf(rolls[0], next?.firstRoll() ?: 0)
    }
}

data class LastFrame(override val rolls: List<Int>) : Frame {
    override var next: Frame? = null
}

class Player {
    private var frames = mutableListOf<Frame>()
    private var rolls = mutableListOf<Int>()
    private var isFinished = false

    fun score(): Int {
        return frames.map(Frame::score).sum()
    }

    fun addRoll(roll: Int) {
        require(!isFinished) { "is finished" }

        rolls += roll
        val sum = rolls.sum()
        val count = rolls.size
        val isLastFrame = frames.size == 9
        val isLastRoll = isLastFrame && (count == 3 || (count == 2 && sum < 10))

        val frame = when {
            isLastRoll -> LastFrame(rolls)
            isLastFrame -> null
            count == 1 && roll == 10 -> StrikeFrame()
            sum == 10 -> SpareFrame(rolls)
            count == 2 -> NormalFrame(rolls)
            else -> null
        }

        frame?.let(this::addFrame)
        if (isLastRoll) isFinished = true
    }

    private fun addFrame(frame: Frame) {
        frames.lastOrNull()?.next = frame
        frames += frame
        rolls = mutableListOf()
    }
}

fun assertScore(expected: Int, rolls: List<Int>) {
    val player = Player()
    rolls.forEach(player::addRoll)
    val actual = player.score()
    if (expected != actual) throw AssertionError("score $expected != $actual")
}

assertScore(1, listOf(1, 0))
assertScore(10, listOf(1, 9))
assertScore(20, listOf(1, 9, 5, 0))
assertScore(28, listOf(10, 5, 4))
assertScore(48, listOf(10, 10, 4, 3))
assertScore(115, listOf(/*1*/ 1, 4, /*2*/ 4, 5, /*3*/ 6, 4, /*4*/ 5, 5, /*5*/ 10, /*6*/ 0, 1, /*7*/ 7, 3, /*8*/ 6, 4, /*9*/ 0, 10, /*10*/ 2, 8, 6))
assertScore(4, listOf(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 3))
assertScore(30, listOf(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 10, 10))
