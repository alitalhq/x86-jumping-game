org 100h
.data
    oyuncu_y db 12          ; Oyuncunun Y koordinati
    oyuncu_x db 5           ; Oyuncunun X koordinati
    engel_y db 12           ; Engellerin Y koordinati
    engel1_x db 38         ; Engel 1 X koordinati
    engel2_x db 50         ; Engel 2 X koordinati
    engel3_x db 62         ; Engel 3 X koordinati
    engel1_tipi db 1       ; Engel 1 tipi: 1=1x1, 2=1x2, 3=2x1
    engel2_tipi db 2       ; Engel 2 tipi
    engel3_tipi db 3       ; Engel 3 tipi
    skor dw 0              ; Skor degiskeni
    skor_str db 'Score: 000$', 0
    ziplaniyor db 0        ; Ziplama bayragi
    ziplama_yonu db 0      ; 0=yerde, 1=yukari, 2=asagi
    oyun_hizi dw 4000h     ; Gecikme degeri
    msj_bitti db '*** GAME OVER ***$', 0
    msj_yenile db 'Press ANY KEY to restart...$', 0
.code
main proc
    mov ax, 0001h      ; 40x25 text modunu sec
    int 10h            ; Ekrani guncelle
    
    ; Imleci gizle
    mov ah, 01h        ; Imlec kontrolu
    mov cx, 2607h      ; Imlec gizle
    int 10h            ; BIOS cagirisi
oyun_dongusu:
    ; --- 1. SKOR GUNCELLE ---
    mov dl, 0          ; X = 0
    mov dh, 0          ; Y = 0
    call imlec_hareket ; Imlec konumu degistir
    call skor_guncelle ; Skor metni olustur
    lea dx, skor_str   ; Mesaj adresini yukle
    mov ah, 09h        ; Metin yazdir komutu
    int 21h            ; DOS cagirisi - yazdir
    
    ; --- 2. SILME ISLEMI ---
    ; Oyuncuyu sil
    mov dl, oyuncu_x   ; X = oyuncu X
    mov dh, oyuncu_y   ; Y = oyuncu Y
    call imlec_hareket ; Imlec hareket ettir
    mov al, ' '        ; Bosluk karakteri
    call karakter_yaz  ; Yazdir
    
    ; Engel 1 sil
    mov dl, engel1_x   ; X = engel 1 X
    mov dh, engel_y    ; Y = engel Y
    call imlec_hareket ; Konuma tasi
    mov al, ' '        ; Bosluk
    call karakter_yaz  ; Yazdir
    ; Tip 2 (dikey) ek kisim sil
    cmp byte ptr [engel1_tipi], 2
    jne atla_engel1_temiz1
    mov dl, engel1_x
    mov dh, engel_y
    dec dh             ; Bir satir yukarisi
    call imlec_hareket
    mov al, ' '
    call karakter_yaz
atla_engel1_temiz1:
    ; Tip 3 (yatay) ek kisim sil
    cmp byte ptr [engel1_tipi], 3
    jne atla_engel1_temiz2
    mov dl, engel1_x
    inc dl             ; Bir sutun saginda
    mov dh, engel_y
    call imlec_hareket
    mov al, ' '
    call karakter_yaz
atla_engel1_temiz2:
    
    ; Engel 2 sil (Engel 1 ile ayni)
    mov dl, engel2_x
    mov dh, engel_y
    call imlec_hareket
    mov al, ' '
    call karakter_yaz
    cmp byte ptr [engel2_tipi], 2
    jne atla_engel2_temiz1
    mov dl, engel2_x
    mov dh, engel_y
    dec dh
    call imlec_hareket
    mov al, ' '
    call karakter_yaz
atla_engel2_temiz1:
    cmp byte ptr [engel2_tipi], 3
    jne atla_engel2_temiz2
    mov dl, engel2_x
    inc dl
    mov dh, engel_y
    call imlec_hareket
    mov al, ' '
    call karakter_yaz
atla_engel2_temiz2:
    
    ; Engel 3 sil (Engel 1, 2 ile ayni)
    mov dl, engel3_x
    mov dh, engel_y
    call imlec_hareket
    mov al, ' '
    call karakter_yaz
    cmp byte ptr [engel3_tipi], 2
    jne atla_engel3_temiz1
    mov dl, engel3_x
    mov dh, engel_y
    dec dh
    call imlec_hareket
    mov al, ' '
    call karakter_yaz
atla_engel3_temiz1:
    cmp byte ptr [engel3_tipi], 3
    jne atla_engel3_temiz2
    mov dl, engel3_x
    inc dl
    mov dh, engel_y
    call imlec_hareket
    mov al, ' '
    call karakter_yaz
atla_engel3_temiz2:
    
    ; --- 3. KLAVYE KONTROLU ---
    mov ah, 01h        ; Tus basili mi kontrol et
    int 16h            ; BIOS cagirisi
    jz gir_girdi       ; Tus yoksa devam
    mov ah, 00h        ; Tusu oku
    int 16h            ; BIOS cagirisi
    cmp al, 32         ; Space tusu mu
    jne gir_girdi      ; Degilse atla
    cmp oyuncu_y, 12   ; Yerdemi kontrol et
    jne gir_girdi      ; Degilse atla
    mov ziplaniyor, 6  ; Ziplama baslat
    
gir_girdi:
    ; --- 4. ENGELLER HAREKETI ---
    ; Engel 1
    dec engel1_x       ; X'i azalt
    cmp engel1_x, 255  ; Negatif oldu mu
    jne tamam_engel1   ; Degilse devam
    mov engel1_x, 62   ; Reset et
    inc skor           ; Skor artir
tamam_engel1:
    ; Engel 2
    dec engel2_x
    cmp engel2_x, 255
    jne tamam_engel2
    mov engel2_x, 62
    inc skor
tamam_engel2:
    ; Engel 3
    dec engel3_x
    cmp engel3_x, 255
    jne tamam_engel3
    mov engel3_x, 62
    inc skor
tamam_engel3:
    
    ; --- 5. ZIPLAMA VE YERCEKIM ---
    cmp ziplaniyor, 0  ; Ziplaniyor mu
    je cekim_kontrol   ; Hayir ise cekim kontrol
    dec oyuncu_y       ; Y'yi azalt (yukari)
    dec ziplaniyor     ; Ziplama gucunu azalt
    mov byte ptr [ziplama_yonu], 1  ; Yukari gidiyoruz
    jmp carpisma_kontrol
    
cekim_kontrol:
    cmp oyuncu_y, 12   ; Yerdemi
    jge yerde_mi       ; Evet ise atla
    inc oyuncu_y       ; Y'yi artir (asagi)
    mov byte ptr [ziplama_yonu], 2  ; Asagi iniyoruz
    jmp carpisma_kontrol
    
yerde_mi:
    mov byte ptr [ziplama_yonu], 0  ; Yerde
    
carpisma_kontrol:
    ; --- 6. CARPI�MA KONTROLU ---
    mov al, oyuncu_x   ; Oyuncu X
    cmp al, engel1_x   ; Engel 1 X ile karsilastir
    je kontrol_engel1_y  ; Esit ise Y kontrol et
    cmp al, engel2_x   ; Engel 2 X ile karsilastir
    je kontrol_engel2_y  ; Esit ise Y kontrol et
    cmp al, engel3_x   ; Engel 3 X ile karsilastir
    je kontrol_engel3_y  ; Esit ise Y kontrol et
    jne ciz_nesneler   ; Yoksa ciz
    
kontrol_engel1_y:
    mov al, oyuncu_y   ; Oyuncu Y
    cmp al, engel_y    ; Engel Y ile karsilastir
    je oyun_bitti      ; Esit ise oyun bitti
    jmp ciz_nesneler
    
kontrol_engel2_y:
    mov al, oyuncu_y
    cmp al, engel_y
    je oyun_bitti
    jmp ciz_nesneler
    
kontrol_engel3_y:
    mov al, oyuncu_y
    cmp al, engel_y
    je oyun_bitti
    
ciz_nesneler:
    ; --- 7. CIZIM ISLEMI ---
    ; Engel 1
    mov al, engel1_x   ; X'i kontrol et
    cmp al, 0          ; 0'dan kucuk mu
    jle atla_ciz_engel1  ; Evet ise atla
    cmp al, 40         ; 40'tan buyuk mu
    jge atla_ciz_engel1  ; Evet ise atla (ekran disinda)
    mov dl, engel1_x   ; X'i yukle
    mov dh, engel_y    ; Y'yi yukle
    call imlec_hareket ; Konuma tasi
    mov al, '#'        ; Engel karakteri
    call karakter_yaz  ; Yazdir
    ; Tip 2 (dikey) ek kisim ciz
    cmp byte ptr [engel1_tipi], 2
    jne atla_engel1_extra
    mov dl, engel1_x
    mov dh, engel_y
    dec dh             ; Yukarida
    call imlec_hareket
    mov al, '#'
    call karakter_yaz
atla_engel1_extra:
    ; Tip 3 (yatay) ek kisim ciz
    cmp byte ptr [engel1_tipi], 3
    jne atla_ciz_engel1
    mov dl, engel1_x
    inc dl             ; Sagida
    cmp dl, 40         ; Ekran disinda mi
    jge atla_ciz_engel1
    mov dh, engel_y
    call imlec_hareket
    mov al, '#'
    call karakter_yaz
atla_ciz_engel1:
    
    ; Engel 2 (Engel 1 ile ayni)
    mov al, engel2_x
    cmp al, 0
    jle atla_ciz_engel2
    cmp al, 40
    jge atla_ciz_engel2
    mov dl, engel2_x
    mov dh, engel_y
    call imlec_hareket
    mov al, '#'
    call karakter_yaz
    cmp byte ptr [engel2_tipi], 2
    jne atla_engel2_extra
    mov dl, engel2_x
    mov dh, engel_y
    dec dh
    call imlec_hareket
    mov al, '#'
    call karakter_yaz
atla_engel2_extra:
    cmp byte ptr [engel2_tipi], 3
    jne atla_ciz_engel2
    mov dl, engel2_x
    inc dl
    cmp dl, 40
    jge atla_ciz_engel2
    mov dh, engel_y
    call imlec_hareket
    mov al, '#'
    call karakter_yaz
atla_ciz_engel2:
    
    ; Engel 3 (Engel 1, 2 ile ayni)
    mov al, engel3_x
    cmp al, 0
    jle atla_ciz_engel3
    cmp al, 40
    jge atla_ciz_engel3
    mov dl, engel3_x
    mov dh, engel_y
    call imlec_hareket
    mov al, '#'
    call karakter_yaz
    cmp byte ptr [engel3_tipi], 2
    jne atla_engel3_extra
    mov dl, engel3_x
    mov dh, engel_y
    dec dh
    call imlec_hareket
    mov al, '#'
    call karakter_yaz
atla_engel3_extra:
    cmp byte ptr [engel3_tipi], 3
    jne atla_ciz_engel3
    mov dl, engel3_x
    inc dl
    cmp dl, 40
    jge atla_ciz_engel3
    mov dh, engel_y
    call imlec_hareket
    mov al, '#'
    call karakter_yaz
atla_ciz_engel3:
    
    ; Oyuncu ciz - hareket yonune gore
    mov dl, oyuncu_x   ; X'i yukle
    mov dh, oyuncu_y   ; Y'yi yukle
    call imlec_hareket ; Konuma tasi
    mov al, [ziplama_yonu]  ; Hareket yonunu oku
    cmp al, 1          ; Yukari mi
    je oyuncu_yukari   ; Evet ise
    cmp al, 2          ; Asagi mi
    je oyuncu_asagi    ; Evet ise
    ; Yoksa yerde
    mov al, 'A'        ; Yerde durumu
    jmp oyuncu_ciz
oyuncu_yukari:
    mov al, '^'        ; Yukari oku
    jmp oyuncu_ciz
oyuncu_asagi:
    mov al, 'V'        ; Asagi oku
oyuncu_ciz:
    call karakter_yaz  ; Yazdir
    
    ; --- 8. HIZ AYARI ---
    mov cx, 00h        ; CX = 0
    mov dx, [oyun_hizi]  ; DX = gecikme degeri
    mov ah, 86h        ; Mikrosaniye cinsinden bekle
    int 15h            ; BIOS cagirisi
    jmp oyun_dongusu   ; Donguye geri don
    
oyun_bitti:
    mov ax, 0001h      ; 40x25 modu sec
    int 10h            ; Ekrani temizle
    
    ; Game Over mesaji
    mov dl, 10         ; X = 10
    mov dh, 8          ; Y = 8
    call imlec_hareket ; Konuma tasi
    mov ah, 09h        ; Metin yazdir
    lea dx, msj_bitti  ; Mesaj adresini yukle
    int 21h            ; DOS cagirisi
    
    ; Skor goster
    mov dl, 8          ; X = 8
    mov dh, 10         ; Y = 10
    call imlec_hareket
    call skor_guncelle ; Skor metni olustur
    mov ah, 09h
    lea dx, skor_str
    int 21h
    
    ; Yeniden baslat mesaji
    mov dl, 2          ; X = 2
    mov dh, 12         ; Y = 12
    call imlec_hareket
    mov ah, 09h
    lea dx, msj_yenile
    int 21h
    
    ; Tus bekle
    mov ah, 00h        ; Tusu oku
    int 16h            ; BIOS cagirisi
    
    ; Degiskenleri sifirla
    mov oyuncu_y, 12   ; Y = 12
    mov oyuncu_x, 5    ; X = 5
    mov engel_y, 12    ; Engel Y = 12
    mov engel1_x, 38   ; Engel 1 X = 38
    mov engel2_x, 50   ; Engel 2 X = 50
    mov engel3_x, 62   ; Engel 3 X = 62
    mov byte ptr [engel1_tipi], 1  ; Engel 1 tipi = 1
    mov byte ptr [engel2_tipi], 2  ; Engel 2 tipi = 2
    mov byte ptr [engel3_tipi], 3  ; Engel 3 tipi = 3
    mov skor, 0        ; Skor = 0
    mov ziplaniyor, 0  ; Ziplaniyor = 0
    mov byte ptr [ziplama_yonu], 0  ; Yonu = 0
    
    ; Ekrani temizle ve oyunu baslat
    mov ax, 0001h      ; 40x25 modu sec
    int 10h            ; Ekrani temizle
    
    mov ah, 01h        ; Imlec kontrolu
    mov cx, 2607h      ; Gizle
    int 10h            ; BIOS cagirisi
    
    jmp oyun_dongusu   ; Oyunu baslat
    
main endp

; --- YARDIMCI FONKSIYONLAR ---
; Imlec konumunu degistir
imlec_hareket proc
    mov ah, 02h        ; Imlec konum komutu
    mov bh, 00h        ; Sayfa 0
    int 10h            ; BIOS cagirisi (DL=X, DH=Y)
    ret                ; Geri don
imlec_hareket endp

; Karakteri yazdir
karakter_yaz proc
    mov ah, 0eh        ; TTY modu - karakter yazdir
    int 10h            ; BIOS cagirisi (AL=karakter)
    ret                ; Geri don
karakter_yaz endp

; Skor sayisini metin stringine cevir
skor_guncelle proc
    mov ax, skor       ; AX = skor
    
    ; Yuzler basamagi
    mov bl, 100        ; BL = 100
    div bl             ; AX / 100
    add al, '0'        ; ASCII karakterine cevir
    mov [skor_str+7], al  ; String[7] = yuzler
    
    ; Onlar ve birler
    mov al, ah         ; AL = kalan
    mov ah, 0          ; AH = 0
    mov bl, 10         ; BL = 10
    div bl             ; AL / 10
    add al, '0'        ; ASCII karakterine cevir
    mov [skor_str+8], al  ; String[8] = onlar
    add ah, '0'        ; ASCII karakterine cevir
    mov [skor_str+9], ah  ; String[9] = birler
    
    ret                ; Geri don
skor_guncelle endp

end