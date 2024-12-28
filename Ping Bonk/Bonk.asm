.386
.model flat,stdcall
option casemap: none
 
include           \masm32\include\windows.inc
include           \masm32\include\user32.inc
include           \masm32\include\kernel32.inc
include           \masm32\include\gdi32.inc
includelib        \masm32\lib\user32.lib
includelib        \masm32\lib\kernel32.lib
includelib        \masm32\lib\gdi32.lib

.data
 
Klasa             db "WinClass",0
TytulOkna         db "Ping Bonk",0

winSizeX          equ 700
middleLine        equ 352
winSizeY          equ 300

winPosX           dd 100
winPosY           dd 100




rec_size_a              dd 50
half_rec_size_a         dd 25
rec_size_b              dd 8
half_rec_size_b         dd 4

player_one_x            dd 100
player_one_y            dd 150

one_start_x             dd 100
one_start_y             dd 150


player_two_x            dd 600
player_two_y            dd 150

two_start_x             dd 600
two_start_y             dd 150

rec_speed               dd 4


KeyMessage              db "Key Pressed: ",0
KeyBuffer               db 10 dup(0)
KeyState                db 256 dup(0)

roundGoing              db 0



ballDir                 db 1

ballX                   dd 0
ballY                   dd 0

ballVx                  dd 0
ballVy                  dd 0

ballSpeed               dd 5

radious                 dd 5


pushPlayer              dd 4

pushPlayerOne             dd 0
pushPlayerTwo             dd 0

ballBaseCol               dd 00fc9b57h
ballHitCol                dd 00fc1c60h
ballCurrCol               dd 00fc9b57h
ballAddCol                dd 00000501h
ballColTime               dd 12
ballColTimer              dd 0

playerOneCol              dd 007b00ffh
playerTwoCol              dd 00ff0044h

middleLineCol             dd 00222222h


playerOneScore            db 0
playerTwoScore            db 0
    
Font		              db "Arial",0

textspace                  db "press [SPACE] to start round "
textspaceCol               dd 00a7c3ebh

textWinOne                db "BLUE WINS!!!",0
textWinTwo                db "RED WINS!!!",0
textRestart               db "press [SPACE] to restart",0

playerOneWinCol              dd 00ff007bh
playerTwoWinCol              dd 004400ffh

scoreText                 db 255 dup (0)  
scoreTextTwo              db 255 dup (0)  
format                    db "%d", 0 

textChanged               db 1


scoreOneCurrCol           dd 00121212h
scoreTwoCurrCol           dd 00121212h
scoreCol                  dd 00121212h
scoreHighlightCol         dd 00929292h
scoreMovCol               dd 00404040h

endGame                   db 0
winCondition              db 6

.data?

hInstance                   HINSTANCE ?

hMainDC		        dd ?
hBackDC		        dd ?
lpBackBitmap	               dd ?
hBackBitmap	               dd ?

textBitmap                  dd ?       ; Handle to the text bitmap
textDC                      dd ?       ; Handle to the compatible DC

hThread		        dd ?
ThreadID	               dd ?
ZakonczThread	               db ?
ThreadExitCode	        dd ?

xa                dd ?
ya                dd ?
da                dd ?

bmi		      BITMAPINFO <>


hFont		           dd ?
hFonttwo		    dd ?

lastKeyOneX             db  ?
lastKeyOneY             db  ?
lastKeyTwoX             db  ?
lastKeyTwoY             db  ?

inputOneX               db  ?
inputOneY               db  ?
inputTwoX               db  ?
inputTwoY               db  ?


.code
start:

	invoke  GetModuleHandle,0
	mov     hInstance,eax
 
	call    WinMain
	invoke  ExitProcess,0
 
WinMain proc

	LOCAL   KlasaOkna:WNDCLASSEX
      LOCAL   msg:MSG
 
	mov     KlasaOkna.cbSize,sizeof(WNDCLASSEX)
	mov     KlasaOkna.style,CS_HREDRAW or CS_VREDRAW
 
	mov     KlasaOkna.lpfnWndProc,offset WndProc
 
 
	push    hInstance
	pop     KlasaOkna.hInstance
 
	mov     KlasaOkna.lpszClassName,offset Klasa
 
 
      invoke  LoadIcon, hInstance, 200
      mov     KlasaOkna.hIcon, eax
      mov     KlasaOkna.hIconSm, eax
 
	invoke  LoadCursor,0,IDC_ARROW
	mov     KlasaOkna.hCursor,eax


      ;obliczanie pozycji WND_LEFT i WND_TOP takich, aby okno bylo na srodku ekranu
      
	invoke  GetSystemMetrics, SM_CXSCREEN
	shr	  eax,1
	sub	  eax,winSizeX/2
	mov	  winPosX,eax

	invoke  GetSystemMetrics, SM_CYSCREEN
	shr	  eax,1
	sub	  eax,winSizeY/2
	mov	  winPosY,eax

 
	invoke  RegisterClassEx, addr KlasaOkna
 
	invoke  CreateWindowEx,
              0,
              addr Klasa,
              addr TytulOkna,
              (WS_SYSMENU or WS_CAPTION or WS_MINIMIZEBOX or WS_VISIBLE or CS_BYTEALIGNWINDOW or CS_BYTEALIGNCLIENT) and not WS_SIZEBOX,
              winPosX,
              winPosY,
              winSizeX,
              winSizeY,
              0,
              0,
              hInstance,
              0  
 
 
.WHILE  TRUE
	  invoke  GetMessage,addr msg,0,0,0
	  .BREAK  .IF(!eax)
	  invoke  TranslateMessage,addr msg
	  invoke  DispatchMessage,addr msg
.ENDW

ret
 
WinMain endp



DrawPointRed proc x:DWORD, y:DWORD

    mov edi,lpBackBitmap

    mov eax, winSizeX
    imul eax,y
    add eax, x
    imul eax,4

    mov dword ptr [edi+eax], 00FF0000h

ret
DrawPointRed endp


DrawPointColor proc x:DWORD, y:DWORD, color:DWORD

    mov edi,lpBackBitmap

    mov eax, winSizeX
    imul eax,y
    add eax, x
    imul eax,4

    mov ebx, color
    mov dword ptr [edi+eax], ebx

ret
DrawPointColor endp



PlotSymmetricPoints proc xc:DWORD, yc:DWORD, x:DWORD, y:DWORD, color:DWORD

    mov eax, xc
    add eax, x
    mov ebx, yc
    add ebx, y 
    invoke DrawPointColor, eax , ebx, color

    mov eax, xc
    sub eax, x
    mov ebx, yc
    add ebx, y 
    invoke DrawPointColor, eax , ebx, color

    mov eax, xc
    add eax, x
    mov ebx, yc
    sub ebx, y 
    invoke DrawPointColor, eax , ebx, color

    mov eax, xc
    sub eax, x
    mov ebx, yc
    sub ebx, y 
    invoke DrawPointColor, eax , ebx, color


    mov eax, xc
    add eax, y
    mov ebx, yc
    add ebx, x
    invoke DrawPointColor, eax , ebx, color

    mov eax, xc
    sub eax, y
    mov ebx, yc
    add ebx, x
    invoke DrawPointColor, eax , ebx, color

    mov eax, xc
    add eax, y
    mov ebx, yc
    sub ebx, x 
    invoke DrawPointColor, eax , ebx, color

    mov eax, xc
    sub eax, y
    mov ebx, yc
    sub ebx, x 
    invoke DrawPointColor, eax , ebx, color
   

ret
PlotSymmetricPoints endp


DrawCircle proc x_c:DWORD, y_c:DWORD, r:DWORD, color:DWORD

    mov eax, 0              
    mov ebx, r
    
    jmp star_drawing_circle

star_drawing_circle:

cmp eax, ebx
jg end_drawing_circle

    mov xa, eax
    mov ya, ebx

    invoke PlotSymmetricPoints,x_c,y_c,eax,ebx,color
    
    mov eax, xa
    mov ebx, ya
    sub ebx, 1

inc eax
inc xa

imul eax,eax
imul ebx,ebx
mov  ecx,r
imul ecx,ecx

mov edx, eax
add edx, ebx

mov eax, xa
mov ebx, ya

cmp edx, ecx
jl skip_dec
    dec ebx
    dec ya
skip_dec:

jmp star_drawing_circle
end_drawing_circle:

ret
DrawCircle endp



DrawRectangle proc x_c:DWORD, y_c:DWORD, a_p:DWORD, b_p:DWORD, color:DWORD

mov eax, b_p
mov xa, eax
shr xa, 1
neg xa

mov ebx, a_p
mov ya, ebx
shr ya, 1


mov ecx, a_p
add ecx, 1


.WHILE ecx > 0


mov eax,x_c
add eax,xa

mov ebx,y_c
add ebx,ya

invoke DrawPointColor,eax,ebx,color

mov eax,x_c
add eax,xa
add eax,b_p

mov ebx,y_c
add ebx,ya

invoke DrawPointColor,eax,ebx,color


dec ya
dec ecx


.ENDW




mov eax, b_p
mov xa, eax
shr xa, 1
neg xa
add xa,1

mov ebx, a_p
mov ya, ebx
shr ya, 1


mov ecx, b_p
sub ecx, 1

.WHILE ecx > 0

mov eax,x_c
add eax,xa

mov ebx,y_c
add ebx,ya

invoke DrawPointColor,eax,ebx,color

mov eax,x_c
add eax,xa

mov ebx,y_c
add ebx,ya
sub ebx,a_p

invoke DrawPointColor,eax,ebx,color

inc xa
dec ecx
.ENDW


ret
DrawRectangle endp



DrawMiddleLine proc x_c:DWORD, color:DWORD

mov ecx, winSizeY

mov eax, x_c
mov xa, eax
mov ebx, 0
mov ya,  0


.WHILE ecx > 0

mov edx,20

jmp compareline


compareline:

cmp edx,0
jg continuedrawingline
jle endLineDraw


continuedrawingline:
cmp edx,10
jge startLineDraw
jle drawEmpyLine


startLineDraw:

mov eax, xa
mov ebx, ya
invoke DrawPointColor,eax,ebx,color

mov eax, xa
sub eax, 1
mov ebx, ya

invoke DrawPointColor,eax,ebx,color

mov eax, xa
add eax, 1
mov ebx, ya

invoke DrawPointColor,eax,ebx,color

inc ya
dec ecx
dec edx

jmp compareline

drawEmpyLine:

inc ya
dec ecx
dec edx

jmp compareline

endLineDraw:

.ENDW


ret
DrawMiddleLine endp



ballColorColl proc


mov eax, ballHitCol
mov ballCurrCol, eax
mov eax, ballColTime
mov ballColTimer, eax

ret
ballColorColl endp



PlayerScores proc player:BYTE

mov al, player

cmp al, 1
jne playertwoscore

;player one score
add playerOneScore, 1
mov ballDir, -1

jmp endscore
playertwoscore:

add playerTwoScore, 1
mov ballDir, 1

endscore:


mov textChanged,1
mov ballVx, 0
mov ballVy, 0

mov eax, middleLine
mov ballX, eax

mov eax, winSizeY
shr eax, 1
mov ballY, eax



mov eax, one_start_x
mov player_one_x, eax

mov eax, one_start_y
mov player_one_y, eax


mov eax, two_start_x
mov player_two_x, eax

mov eax, two_start_y
mov player_two_y, eax


mov roundGoing, 0

ret
PlayerScores endp


HandleWallCollision proc

mov eax, ballX
sub eax, radious
cmp eax,0
jg skipleftcoll

mov ebx, radious
mov ballX, ebx
;neg ballVx

;invoke ballColorColl

    invoke PlayerScores,2
    mov eax, scoreHighlightCol
    mov scoreTwoCurrCol, eax

skipleftcoll:

mov eax, ballX
add eax, radious
add eax, 6
cmp eax, winSizeX
jl skiprightcoll

;invoke ballColorColl

mov ebx, winSizeX
sub ebx, radious
sub ebx, 6
;mov ballX, ebx
;neg ballVx

    invoke PlayerScores,1
    mov eax, scoreHighlightCol
    mov scoreOneCurrCol, eax


skiprightcoll:


mov eax, ballY
sub eax, radious
cmp eax, 0
jg skipupcoll

invoke ballColorColl

mov ebx, radious
mov ballY, ebx
neg ballVy


skipupcoll:


mov eax, ballY
add eax, radious
add eax, 31

cmp eax, winSizeY
jl skipdowncoll

invoke ballColorColl

mov ebx, winSizeY
sub ebx, radious
sub ebx, 31
neg ballVy



skipdowncoll:

ret
HandleWallCollision endp



HandlePlayerOneCollision proc

mov eax, player_one_x
add eax, half_rec_size_b
add eax, radious

mov ebx, player_one_x
sub ebx, half_rec_size_b

mov ecx, player_one_y
add ecx, half_rec_size_a
add ecx, radious

mov edx, player_one_y
sub edx, half_rec_size_a
sub edx, radious

cmp edx, 0
jge bug_fix_upper_wall

mov edx, 0
bug_fix_upper_wall:

.IF (ballX <= eax) && (ballX >= ebx) && (ballY <= ecx) && (ballY >= edx)

    invoke ballColorColl
    

    mov eax, pushPlayer
    mov pushPlayerOne, eax

    mov eax, player_one_x
    add eax, half_rec_size_b
    sub eax, 3

    cmp ballX, eax
    jl ycollPone

        mov eax, player_one_x
        add eax, half_rec_size_b
        add eax, radious
    
        mov ballX, eax


        neg ballVx
        jmp endPoneColl

    ycollPone:

        cmp ballVy, 0
        jl clampOneUp


        ;clamp down

        mov eax, player_one_y
        sub eax, half_rec_size_a
        sub eax, radious
        
        mov ballY, eax
        
        jmp endClampOneY


        clampOneUp:

        ;clamp up

        mov eax, player_one_y
        add eax, half_rec_size_a
        add eax, radious 
        
        mov ballY, eax
        

        endClampOneY:
        
        neg ballVy

    endPoneColl:
    
.ENDIF

ret
HandlePlayerOneCollision endp


HandlePlayerTwoCollision proc

mov eax, player_two_x
add eax, half_rec_size_b
add eax, radious

mov ebx, player_two_x
sub ebx, half_rec_size_b
sub ebx, radious

mov ecx, player_two_y
add ecx, half_rec_size_a
add ecx, radious

mov edx, player_two_y
sub edx, half_rec_size_a
sub edx, radious

cmp edx, 0
jge bug_fix_upper_wall_two

mov edx, 0
bug_fix_upper_wall_two:



.IF (ballX <= eax) && (ballX >= ebx) && (ballY <= ecx) && (ballY >= edx)

    invoke ballColorColl
    

    mov eax, pushPlayer
    mov pushPlayerTwo, eax

    mov eax, player_two_x
    sub eax, half_rec_size_b
    add eax, 3

    cmp ballX, eax
    jg ycollPtwo

        mov eax, player_two_x
        sub eax, half_rec_size_b
        sub eax, radious
    
        mov ballX, eax


        neg ballVx
        jmp endPtwoColl

    ycollPtwo:

        cmp ballVy, 0
        jl clampTwoUp


        ;clamp down

        mov eax, player_two_y
        sub eax, half_rec_size_a
        sub eax, radious
        
        mov ballY, eax
        
        jmp endClampTwoY


        clampTwoUp:

        ;clamp up

        mov eax, player_two_y
        add eax, half_rec_size_a
        add eax, radious 
        
        mov ballY, eax
        

        endClampTwoY:
        
        neg ballVy

    endPtwoColl:
    
.ENDIF

ret
HandlePlayerTwoCollision endp




PlayerKnockBack proc

    mov eax, pushPlayerOne
    cmp eax, 0
    jle dontApplyknockBackOne

        mov eax, player_one_x
        sub eax, pushPlayerOne
        mov player_one_x, eax
        
        sub pushPlayerOne, 1

        
         mov eax, player_one_x
         sub eax, half_rec_size_b

         cmp eax,0
         jl clamp_left_one_push
         jmp dontApplyknockBackOne

         clamp_left_one_push:
            mov eax, half_rec_size_b
            mov player_one_x, eax

            
    dontApplyknockBackOne:

    mov eax, pushPlayerTwo
    cmp eax, 0
    jle dontApplyknockBackTwo

        mov eax, player_two_x
        add eax, pushPlayerTwo
        mov player_two_x, eax
        
        sub pushPlayerTwo, 1


            mov ebx,winSizeX
            sub ebx,rec_size_b
            sub ebx,5
            
            cmp eax,ebx
            jge clamp_right_two_push
            
            jmp dontApplyknockBackTwo

      clamp_right_two_push: 
            mov eax, winSizeX
            sub eax, rec_size_b
            sub eax, 5
            mov player_two_x, eax
 


    dontApplyknockBackTwo:

ret
PlayerKnockBack endp



BallChangeCol proc

    mov eax, ballColTimer
    cmp eax, 0
    jle dontApplyColor

        mov eax, ballAddCol
        add ballCurrCol, eax
        sub ballColTimer, 1
        
        jmp applyColor

    dontApplyColor:
    mov eax, ballBaseCol
    mov ballCurrCol, eax

    applyColor:
ret
BallChangeCol endp



Balling proc

      mov  eax,ballVx
      add  ballX, eax

      mov  eax,ballVy
      add  ballY, eax

      invoke HandlePlayerOneCollision   
      invoke HandlePlayerTwoCollision
      invoke PlayerKnockBack
      
      invoke HandleWallCollision
      
      invoke BallChangeCol
      
ret
Balling endp


FadeText proc

        mov eax, scoreOneCurrCol
        mov ebx, scoreCol
        
        cmp eax, ebx
        jle dontApplyColorOne

            mov textChanged, 1
            
            mov eax, scoreMovCol
            sub scoreOneCurrCol, eax
        
            jmp nexttextfade

        dontApplyColorOne:
        
        mov eax, scoreCol
        mov scoreOneCurrCol, eax



        nexttextfade:


        mov eax, scoreTwoCurrCol
        mov ebx, scoreCol
        
        cmp eax, ebx
        jle dontApplyColorTwo

            mov textChanged, 1
            
            mov eax, scoreMovCol
            sub scoreTwoCurrCol, eax 
        
            jmp endtextfade

        dontApplyColorTwo:
        mov eax, scoreCol
        mov scoreTwoCurrCol, eax

    endtextfade:

ret
FadeText endp


DoGfx proc uses edi hWnd:DWORD
 
inicjalizacja:

     mov eax, middleLine
     mov ballX, eax
      
     mov eax, winSizeY
     shr eax, 1
     mov ballY, eax



	invoke  CreateCompatibleDC,0
	mov	  hBackDC,eax

	mov	  bmi.bmiHeader.biSize,sizeof BITMAPINFOHEADER
	mov	  bmi.bmiHeader.biWidth,winSizeX
	mov	  bmi.bmiHeader.biHeight,(not winSizeY)
	mov	  bmi.bmiHeader.biPlanes,1
	mov	  bmi.bmiHeader.biBitCount,32
	mov	  bmi.bmiHeader.biCompression,BI_RGB
	invoke  CreateDIBSection,hBackDC,addr bmi,DIB_RGB_COLORS,addr lpBackBitmap,0,0
	mov	  hBackBitmap,eax
	invoke  SelectObject,hBackDC,eax

        invoke     CreateFont,15,5,0,0,FW_NORMAL,0,0,0,DEFAULT_CHARSET,0,0,0,0,addr Font
        mov        hFonttwo, eax
        invoke     SelectObject, hBackDC, hFonttwo
        
	  invoke	  SetBkColor, hBackDC, 00000000h
        invoke	  SetTextColor, hBackDC, textspaceCol	


     ;invoke     CreateFont,200,100,0,0,FW_NORMAL,0,0,0,DEFAULT_CHARSET,0,0,0,0,addr Verdana
     ;mov        hFont,eax

     ;invoke	CreateCompatibleDC,0
	;mov	     hBackDC,eax


     ;invoke	SelectObject,hBackDC,hFont

	;invoke	  SetTextColor,hBackDC,006e6e6eh	
	;invoke	  SetBkColor,hBackDC,00000000h



        ; Create a compatible DC for the text rendering
        invoke CreateCompatibleDC, hBackDC
        mov textDC, eax

        ; Create a bitmap for the text and select it into the DC
        invoke CreateCompatibleBitmap, hBackDC, winSizeX, winSizeY
        mov textBitmap, eax
        invoke SelectObject, textDC, textBitmap

        ; Clear the background
        invoke PatBlt, textDC, 0, 0, winSizeX, winSizeY, BLACKNESS

        ; Render the text onto the textDC
        invoke     CreateFont,240,105,0,0,FW_NORMAL,0,0,0,DEFAULT_CHARSET,0,0,0,0,addr Font
        mov        hFont, eax
        invoke     SelectObject, textDC, hFont
        
        invoke	  SetTextColor, textDC, scoreCol	
	  invoke	  SetBkColor, textDC,00000000h

        ;invoke SetBkMode, textDC, OPAQUE

        ;invoke wsprintf, addr scoreText, addr format, playerOneScore
        ;invoke TextOut, textDC, 10, 10, addr scoreText, sizeof scoreText - 1

        ;invoke wsprintf, addr scoreTextTwo, addr format, playerTwoScore
        ;invoke TextOut, textDC, 10, 10, addr scoreText, sizeof scoreText - 1


@@:	invoke  GetDC,hWnd
	test	  eax,eax
	jz	  @B
	mov     hMainDC,eax

rysowanie:

	mov	  ecx,winSizeX*winSizeY
	mov	  edi,lpBackBitmap
	xor	  eax,eax
	rep	  stosd

	;mov	  edi,lpBackBitmap
	;mov	  dword ptr [edi+( 40 * winSizeX + 30 )*4], 00FF0000h


      invoke   Balling
      invoke   FadeText

      .IF textChanged == 1
      
        ; Re-render the text onto the back buffer or textDC
        invoke   PatBlt, textDC, 0, 0, winSizeX, winSizeY, BLACKNESS
        ;invoke SetBkMode, textDC, OPAQUE

        invoke   SetTextColor, textDC, scoreOneCurrCol

        invoke   wsprintf, addr scoreText, addr format, playerOneScore
        invoke   TextOut,textDC,105,25, addr scoreText,sizeof scoreText-1


        invoke   SetTextColor, textDC, scoreTwoCurrCol

        invoke   wsprintf, addr scoreTextTwo, addr format, playerTwoScore
        invoke   TextOut,textDC,465,25, addr scoreTextTwo,sizeof scoreTextTwo-1
        
        mov textChanged, 0 
        
      .ENDIF
      
      invoke  BitBlt,hBackDC,0,0,winSizeX,winSizeY,textDC,0,0,SRCCOPY



      invoke   DrawMiddleLine,middleLine, middleLineCol
      invoke   DrawCircle,ballX,ballY,radious,ballCurrCol
      
      invoke   DrawRectangle, player_one_x, player_one_y, rec_size_a, rec_size_b, playerOneCol
      invoke   DrawRectangle, player_two_x, player_two_y, rec_size_a, rec_size_b, playerTwoCol



            mov al, playerOneScore
            mov ah, winCondition
            cmp al, ah
            jne nextwin

            mov endGame, 1

            nextwin:

            mov al ,playerTwoScore
            mov ah, winCondition
            cmp al, ah
            jne noWin

            mov endGame, 2

            noWin:


      .IF endGame == 0

            mov al, roundGoing
            cmp al, 0
            jne playerloop

            invoke   SetTextColor, hBackDC, textspaceCol
            invoke	 SetBkColor, hBackDC, 00000000h
            invoke   TextOut,hBackDC,267,20, addr textspace ,sizeof textspace-1
      
      playerloop:
      
      jmp if_w    
        
      if_w:
            cmp lastKeyOneY, 'W'
            je do_if_w
            cmp lastKeyOneY, 'S'
            je do_if_s
            jmp if_a

      if_a:
            cmp lastKeyOneX, 'A'
            je do_if_a
            cmp lastKeyOneX, 'D'
            je do_if_d
            jmp if_arr_up

      if_arr_up:
            cmp lastKeyTwoY, '&'
            je do_if_arr_up
            cmp lastKeyTwoY, '('
            je do_if_arr_down
            jmp if_arr_left

      if_arr_left:
            cmp lastKeyTwoX, '%'
            je do_if_arr_left
            cmp lastKeyTwoX, "'"
            je do_if_arr_right
            jmp skip_keys


      do_if_w:
            mov eax, rec_speed
            sub player_one_y,eax

            mov eax, player_one_y
            sub eax, half_rec_size_a

            cmp eax,0
            jl clamp_up_one
            
            jmp if_a

      clamp_up_one:
            mov eax, half_rec_size_a
            mov player_one_y, eax
            jmp if_a


      do_if_s:
            mov eax, rec_speed
            add player_one_y,eax

            mov eax, player_one_y
            add eax, rec_size_a
            add eax, 6

            cmp eax,winSizeY
            jg clamp_down_one
            
            jmp if_a

      clamp_down_one: 
            mov eax, winSizeY
            sub eax, rec_size_a
            sub eax, 6
            mov player_one_y, eax
            jmp if_a


       do_if_a:
            mov eax, rec_speed
            sub player_one_x,eax

            mov eax, player_one_x
            sub eax, half_rec_size_b

            cmp eax,0
            jl clamp_left_one
            
            jmp if_arr_up

      clamp_left_one:
            mov eax, half_rec_size_b
            mov player_one_x, eax
            jmp if_arr_up


      do_if_d:

            mov eax, pushPlayerOne
            cmp eax, 0
            jg if_arr_up

            mov eax, rec_speed
            add player_one_x,eax

            mov eax, player_one_x
            add eax, half_rec_size_b

            mov ebx,middleLine
            sub ebx,1
            
            cmp eax,ebx
            jge clamp_right_one

            jmp if_arr_up

      clamp_right_one: 
            mov eax, middleLine
            sub eax, half_rec_size_b
            sub eax, 2
            mov player_one_x, eax
            jmp if_arr_up




      do_if_arr_up:
            mov eax, rec_speed
            sub player_two_y,eax

            mov eax, player_two_y
            sub eax, half_rec_size_a

            cmp eax,0
            jl clamp_up_two
            
            jmp if_arr_left

      clamp_up_two:
            mov eax, half_rec_size_a
            mov player_two_y, eax
            jmp if_arr_left


      do_if_arr_down:
            mov eax, rec_speed
            add player_two_y,eax

            mov eax, player_two_y
            add eax, rec_size_a
            add eax, 6

            cmp eax,winSizeY
            jg clamp_down_two
            
            jmp if_arr_left

      clamp_down_two: 
            mov eax, winSizeY
            sub eax, rec_size_a
            sub eax, 6
            mov player_two_y, eax
            jmp if_arr_left


       do_if_arr_left:
       
            mov eax, pushPlayerTwo
            cmp eax, 0
            jg skip_keys

            
            mov eax, rec_speed
            sub player_two_x,eax

            mov eax, player_two_x
            sub eax, half_rec_size_b

            cmp eax,middleLine
            jl clamp_left_two
            
            jmp skip_keys

      clamp_left_two:
            mov eax, half_rec_size_b
            add eax, middleLine
            add eax, 2
            mov player_two_x, eax
            jmp skip_keys


      do_if_arr_right:
            mov eax, rec_speed
            add player_two_x,eax

            mov eax, player_two_x
            add eax, rec_size_b

            mov ebx,winSizeX
            sub ebx,rec_size_b
            sub ebx,5
            
            cmp eax,ebx
            jge clamp_right_two
            
            jmp skip_keys

      clamp_right_two: 
            mov eax, winSizeX
            sub eax, rec_size_b
            sub eax, 5
            mov player_two_x, eax
            jmp skip_keys

            
   
      skip_keys:
      
                ;end of player loop


       .ElSEIF endGame == 1


            invoke   SetTextColor, hBackDC, playerOneWinCol
            invoke	 SetBkColor, hBackDC, 00000000h
            invoke   TextOut,hBackDC,316,20, addr textWinOne ,sizeof textWinOne-1
            invoke   TextOut,hBackDC,284,40, addr textRestart ,sizeof textRestart-1

        .ElSEIF endGame == 2


            invoke   SetTextColor, hBackDC, playerTwoWinCol
            invoke	 SetBkColor, hBackDC, 00000000h
            invoke   TextOut,hBackDC,316,20, addr textWinTwo ,sizeof textWinTwo-1
            invoke   TextOut,hBackDC,284,40, addr textRestart ,sizeof textRestart-1

       .ENDIF

	invoke  BitBlt,hMainDC,0,0,winSizeX,winSizeY,hBackDC,0,0,SRCCOPY

	invoke  Sleep,10

	cmp	  ZakonczThread,1
	jne	  rysowanie

deinicjalizacja:

	invoke  ReleaseDC,hWnd,hMainDC

	invoke  DeleteDC,hBackDC
	invoke  DeleteObject,hBackBitmap
	ret

DoGfx endp


UpateLastKeys proc

                ; Update last key for player one
        cmp eax, 'W'
        je updateLastKeyOneY
        cmp eax, 'S'
        je updateLastKeyOneY
        cmp eax, 'A'
        je updateLastKeyOneX
        cmp eax, 'D'
        je updateLastKeyOneX

                ; Update last key for player two
        cmp eax, '&'  ; Arrow up
        je updateLastKeyTwoY
        cmp eax, '('  ; Arrow down
        je updateLastKeyTwoY
        cmp eax, '%'  ; Arrow left
        je updateLastKeyTwoX
        cmp eax, "'" ; Arrow right
        je updateLastKeyTwoX
        jmp skipUpdate

        updateLastKeyOneX:
            mov lastKeyOneX, al
            jmp skipUpdate

        updateLastKeyOneY:
            mov lastKeyOneY, al
            jmp skipUpdate

        updateLastKeyTwoX:
            mov lastKeyTwoX, al
            jmp skipUpdate

        updateLastKeyTwoY:
            mov lastKeyTwoY, al
        skipUpdate:

ret
UpateLastKeys endp


UpateKeys proc

                ; Update last key for player one
            cmp KeyState['W'], 1 
            je updateLastKeyOneYW
            cmp KeyState['S'], 1
            je updateLastKeyOneYS

            compareXOne:
            cmp KeyState['A'], 1
            je updateLastKeyOneXA
            cmp KeyState['D'], 1
            je updateLastKeyOneXD

            comparePlayerTwo:
                ; Update last key for player two
            cmp KeyState['&'], 1   ; Arrow up
            je updateLastKeyTwoYUp
            cmp KeyState['('], 1   ; Arrow down
            je updateLastKeyTwoYDown

            compareXTwo:
            cmp KeyState['%'], 1; Arrow left
            je updateLastKeyTwoXLeft
            cmp KeyState["'"], 1 ; Arrow right
            je updateLastKeyTwoXRight
            jmp skipUpdate

            updateLastKeyOneYW:
                mov lastKeyOneY, 'W'
                jmp compareXOne

            updateLastKeyOneYS:
                mov lastKeyOneY, 'S'
                jmp compareXOne

            updateLastKeyOneXA:
                mov lastKeyOneX, 'A'
                jmp comparePlayerTwo

            updateLastKeyOneXD:
                mov lastKeyOneX, 'D'
                jmp comparePlayerTwo

            updateLastKeyTwoYUp:
                mov lastKeyTwoY, '&'
                jmp compareXTwo

            updateLastKeyTwoYDown:
                mov lastKeyTwoY, '('
                jmp compareXTwo

            updateLastKeyTwoXLeft:
                mov lastKeyTwoX, '%'
                jmp skipUpdate

            updateLastKeyTwoXRight:
                mov lastKeyTwoX, "'"
            skipUpdate:

ret
UpateKeys endp



ResetKeys proc

; Reset last key if it matches the released key
            cmp lastKeyOneX, al
            je resetLastKeyOneX
            cmp lastKeyOneY, al
            je resetLastKeyOneY
            cmp lastKeyTwoX, al
            je resetLastKeyTwoX
            cmp lastKeyTwoY, al
            je resetLastKeyTwoY
            jmp skipKeyUp

            resetLastKeyOneX:
                mov lastKeyOneX, 0
                jmp skipKeyUp

            resetLastKeyOneY:
                mov lastKeyOneY, 0
                jmp skipKeyUp

            resetLastKeyTwoX:
                mov lastKeyTwoX, 0
                jmp skipKeyUp

            resetLastKeyTwoY:
                mov lastKeyTwoY, 0
            skipKeyUp:

ret
ResetKeys endp


StartRound proc 


.IF endGame == 0
      cmp roundGoing, 0
      je canStartRound
      jne nospace

      

      canStartRound:
      cmp al, ' '
      je yesspace
      jne nospace
    
      yesspace:
      mov roundGoing, 1

      cmp ballDir, 0
      jl  goleft
      jge goright

      goleft:
      mov ballVx, -1
      mov ballVy, -1

      jmp gonext
      
      goright:
      
      mov ballVx, 1
      mov ballVy, 1

      gonext:

      mov eax, ballVx
      imul eax, ballSpeed
      mov ballVx, eax 
      
      mov eax, ballVy
      imul eax, ballSpeed
      mov ballVy, eax 
            
      nospace:

.ELSE

    cmp al, ' '
    jne noRestart

    mov playerOneScore, 0
    mov playerTwoScore, 0

    mov textChanged, 1

    mov endGame, 0

    mov ballDir, 1

    noRestart:
    
.ENDIF

ret
StartRound endp

 
WndProc proc hWnd:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM     

    .IF uMsg == WM_DESTROY

            invoke PostQuitMessage,0
    
    .ELSEIF uMsg==WM_CREATE

            invoke CreateThread,0,0,addr DoGfx,hWnd,0,addr ThreadID
            mov    hThread,eax
     
    .ELSEIF uMsg==WM_CLOSE

            mov    ZakonczThread,1
@@:         invoke GetExitCodeThread,hThread,addr ThreadExitCode
            cmp    ThreadExitCode,STILL_ACTIVE
            je     @B
            invoke DestroyWindow,hWnd
            
    .ELSEIF uMsg == WM_KEYDOWN
            mov eax, wParam
            mov KeyState[eax], 1        ; Mark the key as pressed
            ;mov KeyBuffer[0], al

            invoke UpateLastKeys

            invoke StartRound
      
            
    .ELSEIF uMsg == WM_KEYUP
    
            mov eax, wParam
            mov KeyState[eax], 0        ; Mark the key as released

            invoke ResetKeys
            invoke UpateKeys
            
    .ELSEIF uMsg == WM_NCHITTEST
    
            invoke DefWindowProc, hWnd, uMsg, wParam, lParam
            cmp eax, HTCAPTION
            je prevmouse

            prevmouse:
            mov eax, HTCLIENT
            ret
    .ELSE
    
            invoke DefWindowProc,hWnd,uMsg, wParam,lParam
            ret
    
    .ENDIF
ret
 
WndProc endp
 
end start
