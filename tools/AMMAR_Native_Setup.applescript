-- AMMAR YT GTA V - Native Xcode / IPA Setup
-- Open this file in macOS Script Editor and press Run.
-- This UI requires the user's legally usable, exact game build 8b0b5899ed.
-- The script will never download or bypass the required GTA game engine/shaders.

on run
    display dialog "AMMAR YT GTA V — إعداد اللعبة الحقيقية" & return & return & "هذه الأداة تجهز تطبيق PlayGTA5Native الأصلي، وليس نسخة المعاينة. تحتاج إلى ملفات game.wasm والـShaders والداتا المتوافقة من مصدر مصرح به." buttons {"إلغاء", "متابعة"} default button "متابعة" with icon note
    set repoFolder to choose folder with prompt "اختر مجلد مستودع G على الماك (يحتوي app و build_ipa.sh)"
    set dataFolder to choose folder with prompt "اختر مجلد ملفات GTA V المتوافقة، الذي يحتوي data/ و b/"
    set rootPath to POSIX path of repoFolder
    set dataPath to POSIX path of dataFolder

    set actionChoice to button returned of (display dialog "ماذا تريد إنشاءه؟" & return & return & "تجهيز Xcode: لتشغيل PlayGTA5Native من زر التشغيل في Xcode." & return & "بناء IPA: يصدر ملف IPA غير موقّع، ويحتاج توقيعًا صالحًا لهاتفك." buttons {"إلغاء", "تجهيز Xcode", "بناء IPA"} default button "تجهيز Xcode" with icon note)
    if actionChoice is "إلغاء" then return

    set repoQuoted to quoted form of rootPath
    set dataQuoted to quoted form of dataPath
    set logPath to rootPath & "app/Build/AMMAR-native-setup.log"
    set logQuoted to quoted form of logPath

    -- Git and xcodegen may be installed under Homebrew's Apple Silicon prefix.
    set setupEnv to "export PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin; "
    set preflight to "/usr/bin/python3 app/Scripts/check_game_files.py --mirror " & dataQuoted
    set prepare to "/usr/bin/python3 app/Scripts/prepare.py --mirror " & dataQuoted & " --sdk iphoneos --sdk iphonesimulator"

    if actionChoice is "تجهيز Xcode" then
        set job to preflight & " && " & prepare
    else
        set job to preflight & " && /bin/bash build_ipa.sh --mirror " & dataQuoted & " --free"
    end if

    set buildScript to setupEnv & "cd " & repoQuoted & " && test -f app/Scripts/check_game_files.py && mkdir -p app/Build && (" & job & ") > " & logQuoted & " 2>&1"
    try
        with timeout of 10800 seconds
            do shell script buildScript
        end timeout
        if actionChoice is "تجهيز Xcode" then
            do shell script "open -a Xcode " & quoted form of (rootPath & "app/PlayGTA5Native.xcodeproj")
            display dialog "تم تجهيز مشروع PlayGTA5Native وفتحه في Xcode." & return & "اختر الآيفون أو المحاكي الصحيح، ثم اضبط Signing & Capabilities إذا كنت على جهاز حقيقي، واضغط Command + R." buttons {"حسنًا"} default button "حسنًا" with icon note
        else
            set originalIPA to rootPath & "GTA5Port.ipa"
            set brandedIPA to rootPath & "AMMAR-YT-GTA-V.ipa"
            do shell script "test -s " & quoted form of originalIPA & " && /usr/bin/ditto " & quoted form of originalIPA & " " & quoted form of brandedIPA
            do shell script "open -R " & quoted form of brandedIPA
            display dialog "تم إنشاء AMMAR-YT-GTA-V.ipa، وهو ملف غير موقّع." & return & "يجب توقيعه بشهادة تسمح بالتثبيت على جهازك. اللعبة تحتاج ملفات الداتا المتوافقة على الهاتف أو رابط الخادم." buttons {"حسنًا"} default button "حسنًا" with icon note
        end if
    on error errorText number errorCode
        set logTail to errorText
        try
            set logTail to do shell script "/usr/bin/tail -n 12 " & logQuoted
        end try
        display dialog "تعذر إكمال إعداد المحرك (خطأ " & errorCode & ")." & return & return & "آخر سطور الفحص:" & return & logTail & return & return & "ملف السجل محفوظ في app/Build/AMMAR-native-setup.log." buttons {"حسنًا"} default button "حسنًا" with icon stop
    end try
end run
