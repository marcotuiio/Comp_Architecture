### File for creating macros (subroutines)

.macro terminate
	addi $v0, $zero, 10  # Encerrando o programa
	syscall
.end_macro

## PRINTS
.macro print_int(%x)
	add $a0, %x, $zero  # Carregando $a0 com int %x a printar
	addi $v0, $zero, 1  # Informando que o syscall deve printar int
	syscall
.end_macro

.macro print_float(%x)
	add $f12, %x, $zero  # Carregando $a0 com float %x a printar
	addi $v0, $zero, 2  # Informando que o syscall deve printar int
	syscall
.end_macro

.macro print_str(%str)
	.data
		toPrint: .asciiz %str
	.text	
	la $a0, toPrint  # Carregando em $a0 a string a printar (Separador)
	addi $v0, $zero, 4  # Informando que o syscall deve printar string
	syscall
.end_macro

.macro print_char(%c)
	add $a0, %x, $zero  # Carregando $a0 com o char %c a printar
	addi $v0, $zero, 11  # Informando que o syscall deve printar char
	syscall
.end_macro 

## SCANS
.macro scan_int(%a)
	addi $v0, $zero, 5  # Informando que o syscall deverá ler um int
	syscall
	add %a, $v0, $zero  # Armazenando A em $s0
.end_macro

.macro scan_float(%a)
	addi $v0, $zero, 6  # Informando que o syscall deverá ler um float
	syscall
	add %a, $f0, $zero  # Armazenando A em $s0
.end_macro

.macro scan_char(%a)
	addi $v0, $zero, 12  # Informando que o syscall deverá ler um float
	syscall
	add %a, $v0, $zero  # Armazenando A em $s0
.end_macro
