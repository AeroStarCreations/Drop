-- Audio library guide: https://docs.coronalabs.com/guide/media/audioSystem/index.html
-- Audio library docs: https://docs.coronalabs.com/api/library/audio/index.html
--
-- Audio files have an extra 500 milliseconds saved on the end for smooth
-- looping transitions. The audio files fade out during that time

-- Requires -------------------------------------------------------------------[
local timers = require("other.timers")

-- Private Members ------------------------------------------------------------[
local TAG = "sounds.lua: "
local FADE_OUT_TIME = 500
local FADE_IN_TIME = 1000

local activeChannel
local playbackStartTime
local playbackTime
local soundTable
local introTimer
local trackTimer
local phase
local shouldGoToNextPhase
local playCurrentPhaseAudio

local soundInfo = {
    [1] = {
        file = "audio/phase1.wav",
        duration = 8000
    },
    [2] = {
        file = "audio/phase2.wav",
        duration = 8000
    },
    [3] = {
        file = "audio/phase3.wav",
        duration = 8000
    },
    [4] = {
        file = "audio/phase4.wav",
        duration = 8000
    },
    [5] = {
        file = "audio/phase5.wav",
        duration = 16000
    },
    [6] = {
        file = "audio/phase6.wav",
        duration = 16000
    },
    [7] = {
        file = "audio/phase7.wav",
        duration = 16000
    },
    [8] = {
        file = "audio/intro.wav",
        duration = 8000
    },  -- intro
}
local introIndex = #soundInfo

-- Private Functions ----------------------------------------------------------[
local function startPlaybackTimer()
    playbackTime = 0
    playbackStartTime = system.getTimer()
end

local function pausePlaybackTimer()
    playbackTime = playbackTime + (system.getTimer() - playbackStartTime)
end

local function resumePlaybackTimer()
    playbackStartTime = system.getTimer()
end

local function getPlaybackPosition()
    return playbackTime % soundInfo[phase].duration
end

local function disposeActiveChannel()
    audio.stop(activeChannel)
    if phase ~= 1 and phase ~= introIndex then
        audio.dispose(soundTable[phase])
        soundTable[phase] = nil
    end
end

local function cleanPreviousPhaseSound()
    local oldPhase = phase - 1
    if oldPhase > 1 then
        audio.dispose(soundTable[oldPhase])
        soundTable[oldPhase] = nil
    end
end

local function configureNextPhase()
    phase = phase % introIndex + 1
    local time = soundInfo[phase].duration
    timers.cancel(trackTimer)
    trackTimer = timers.createTimer(time, playCurrentPhaseAudio, "", -1)
    startPlaybackTimer()
end

local function loadFutureTrack()
    local futurePhase = phase + 1
    if futurePhase < introIndex then
        local fileName = soundInfo[futurePhase].file
        soundTable[futurePhase] = audio.loadSound(fileName)
    end
end

local function checkForNextPhase()
    if shouldGoToNextPhase then
        cleanPreviousPhaseSound()
        configureNextPhase()
        loadFutureTrack()
        shouldGoToNextPhase = false
    end
end

function playCurrentPhaseAudio(shouldFadeIn)
    activeChannel = activeChannel % 2 + 1
    checkForNextPhase()
    audio.setVolume(audio.getVolume(), { channel = activeChannel })
    audio.play(soundTable[phase], {
        channel = activeChannel,
        fadeIn = (shouldFadeIn and FADE_IN_TIME) or 0
    })
end

local function introTimerListener(event)
    playCurrentPhaseAudio()
    introTimer = nil
end

local function playMusicFromBeginning()
    activeChannel = 1
    phase = introIndex
    playCurrentPhaseAudio()
    startPlaybackTimer()
    shouldGoToNextPhase = true
    local introDuration = soundInfo[introIndex].duration
    introTimer = timers.createTimer(introDuration, introTimerListener, "")
end

local function pauseMusic()
    local time = FADE_OUT_TIME
    audio.fadeOut({
        channel = activeChannel,
        time = time
    })
    pausePlaybackTimer()
    timers.pause(introTimer)
    timers.pause(trackTimer)
end

local function resumeMusic()
    playCurrentPhaseAudio(true)
    audio.seek(getPlaybackPosition(), {channel = activeChannel})
    resumePlaybackTimer()
    timers.resume(introTimer)
    timers.resume(trackTimer)
end

-- Initialization -------------------------------------------------------------[
audio.reserveChannels(2)
soundTable = {
    [1] = audio.loadSound(soundInfo[1].file),
    [introIndex] = audio.loadSound(soundInfo[introIndex].file)
}

-- Public Members -------------------------------------------------------------[
local v = {}

function v.playMusic()
    playMusicFromBeginning()
end

function v.stopMusic()
    disposeActiveChannel()
    timers.cancel(introTimer)
    timers.cancel(trackTimer)
end

function v.pauseMusic()
    pauseMusic()
end

function v.resumeMusic()
    resumeMusic()
end

function v.nextPhase()
    shouldGoToNextPhase = true
end

return v
