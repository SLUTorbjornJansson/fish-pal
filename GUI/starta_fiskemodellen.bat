SET PATH=./jars;%PATH%
java\bin\java.exe -Xverify:none -XX:+UseParallelGC -XX:MaxNewSize=32M -XX:NewSize=32M -Djava.library.path=jars  -jar jars\gig.jar fisk.ini definiera_fiskemodellens_gui.xml

pause