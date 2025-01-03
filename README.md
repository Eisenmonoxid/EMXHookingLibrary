# EMXHookingLibrary
A lua script hook for the games "The Settlers 6" and "The Settlers 6: History Edition". Will very likely never be truly finished ;)
If you want to use the hook library in your map and you need help, ask on my [Discord](https://discord.gg/7SGkQtAAET).

Uses the **"BigNum.lua"** library. Special thanks to the authors!

## Usage
Include the file **"emxhooklib.bin"** in your map folder and load it with **"Script.Load()"** in the global map script. Then call the function `EMXHookLibrary.Initialize(_useLoadGameOverride, _maxMemorySizeToAllocate, _useGeneralGameBugfixes)` and after that, you can use the exported methods (listed below) however you like. All three function arguments are optional. The boolean return value suggests if the initialization was successful.

Hint: To reset the hooked values, use the function argument `EMXHookLibrary.Initialize(true)` and have the function `EMXHookLibrary_ResetValues(_source, _stringParam)` in your global map script, which will be automatically called when the map is closed. Put all your functions in there to reset your changed values.

Should you be interested in an example map script that uses the features of the HookLibrary extensively, look [Here](https://github.com/Eisenmonoxid/MapScripts_Bloodmoon) and [Here](https://github.com/Eisenmonoxid/MapScripts_Talkessel).

## Bugfixes
Currently, the Hook supports the following general game bug fixes. These become active when the third argument to the **Initialize** function is **true**. In Multiplayer maps, set the first argument **_useLoadGameOverride** to **nil**.

- _Fix Entertainercrash: When dismissing an entertainer, the game would crash._
- _Fix GUI.SendScriptCommand: In the History Edition Multiplayer (without activated Development-Mode), the function was not executed._

## Features
For a comprehensive list of features, take a look at either the [German Features](https://github.com/Eisenmonoxid/EMXHookingLibrary/blob/main/FEATURES_DE.md) or the [English Features](https://github.com/Eisenmonoxid/EMXHookingLibrary/blob/main/FEATURES_EN.md) file.
