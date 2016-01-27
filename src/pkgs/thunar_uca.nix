{ writeText, photofetcher }:

writeText "uca.xml.in" ''
  <?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE actions [
    <!ELEMENT actions (action)+>

    <!ELEMENT action (icon|patterns|name|unique-id|command|description|directories|audio-files|image-files|other-files|text-files|video-files)*>

    <!ELEMENT icon (#PCDATA)>
    <!ELEMENT command (#PCDATA)>
    <!ELEMENT patterns (#PCDATA)>

    <!ELEMENT name (#PCDATA)>
    <!ATTLIST name xml:lang CDATA #IMPLIED>

    <!ELEMENT unique-id (#PCDATA)>

    <!ELEMENT description (#PCDATA)>
    <!ATTLIST description xml:lang CDATA #IMPLIED>

    <!ELEMENT startup-notify EMPTY>

    <!ELEMENT directories EMPTY>
    <!ELEMENT audio-files EMPTY>
    <!ELEMENT image-files EMPTY>
    <!ELEMENT other-files EMPTY>
    <!ELEMENT text-files EMPTY>
    <!ELEMENT video-files EMPTY>
  ]>

  <actions>

    <action>
      <icon>utilities-terminal</icon>
      <patterns>*</patterns>
      <_name>Open Terminal Here</_name>
      <command>exo-open --working-directory %f --launch TerminalEmulator</command>
      <_description>Example for a custom action</_description>
      <startup-notify/>
      <directories/>
    </action>
    <action>
      <icon>utilities-terminal</icon>
      <name>Open terminal near</name>
      <unique-id>1389292937476516-5</unique-id>
      <command>exo-open --working-directory %d --launch TerminalEmulator</command>
      <description>Открывает терминал в этой папке</description>
      <patterns>*</patterns>
      <startup-notify/>
      <audio-files/>
      <image-files/>
      <other-files/>
      <text-files/>
      <video-files/>
    </action>
    <action>
      <icon>camera-photo</icon>
      <name>Copy images from the camera</name>
      <name xml:lang="ru">Скопировать фотографии из фотоаппарата</name>
      <unique-id>1389349476228970-8</unique-id>
      <command>photofetcher %f</command>
      <description>Копирует фотографии из фотоаппарата в эту папку</description>
      <patterns>*</patterns>
      <directories/>
    </action>
    <action>
      <icon>document-send</icon>
      <name>Переместить файлы в другой каталог</name>
      <unique-id>1389351656678468-9</unique-id>
      <command>photomove %F</command>
      <description>Перемещает выбранные файлы в выбранный каталог</description>
      <patterns>*</patterns>
      <audio-files/>
      <image-files/>
      <video-files/>
    </action>
    <action>
      <icon>mime-video</icon>
      <name>Понизить частоту кадров видеофайла</name>
      <unique-id>1389351656678468-10</unique-id>
      <command>videoconvert %F</command>
      <description>Понижает частоту кадров видео</description>
      <patterns>*</patterns>
      <video-files/>
    </action>
    <action>
      <icon>gtk-find</icon>
      <name>Уменьшить фотографии в этом каталоге</name>
      <unique-id>1389351656678468-11</unique-id>
      <command>photoresize %F</command>
      <description>Уменьшает все фотографии в этом каталоге</description>
      <patterns>*</patterns>
      <directories/>
      <audio-files/>
      <image-files/>
      <video-files/>
    </action>

  </actions>
''
