SpriteSheetMakingTool
=====================
빌드 환경 :  Adobe AIR SDK 13.0, Android


res/in/ 위치에 있는 이미지 파일들을 이용하여 SpriteSheet와 atlas.xml 파일을 생성합니다.

생성된 spritesheet.png 파일은 2의 승수 크기로 제작됩니다.

디바이스에 출력된 각각의 이미지 터치 시 경계를 선택적으로 볼 수 있습니다.


Input Image 는 applicationDirectory/res/in/ 에 위치. (png, jpg, bmp 파일 사용가능).

Output File(atlas.xml, spritesheet.png)은 확인을 위해 임시로 documentsDirectory/res/out/ 위치에 저장.



      //Android documentsDirectory   :   /mnt/sdcard
      //iOS documentsDirectory       :   /var/mobile/Applications/uid/Documents
