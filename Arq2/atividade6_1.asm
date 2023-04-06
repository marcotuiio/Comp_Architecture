.include "macros.asm"

.data
	Error: .asciiz "Arquivo nao encontrado!\n"
	FilePath: .asciiz "C:\\Users\\marco\\Desktop\\UEL\\Comp_Architecture\\Arq2\\dados1.txt"
	Buffer: .asciiz " "
	vetor: .space 512
.text

	main:
		
		jal fopen
		move $s0, $v0
		
		la $s1, vetor
		li $s2, 0 # indice do vetor
		jal fscanf
		print_str("\n\n Vetor lido de dados1.txt: ")
		jal print_array
		jal fclose
		
		li $t2, -1
		jal maior
		print_str("\n\n A) Maior numero do vetor: ")
		print_int($t2)

		li $t2, 9999
		jal menor
		print_str("\n\n B) Menor numero do vetor: ")
		print_int($t2)

		li $t2, 0
		li $t3, 0
		jal impares_pares

		jal fopen
		li $t0, 0 # contador
		jal count_chars
		print_str("\n\n I) Numero de characters no arquivo: ")
		print_int($t0)
		jal fclose

		terminate
		
	fopen:
		la $a0, FilePath
		li $a1, 0 # somente leitura
		li $v0, 13
		syscall
		blez $v0, erro # verifica se ocorreu erro ao abrir o arquivo
		jr $ra # retorna com o identificador do arquivo em $v0
		erro: 
			la $a0, Error
			li $v0, 4
			syscall
			li $v0, 10
			syscall

	fclose:
		move $a0, $s0
		li $v0, 16
		syscall
		jr $ra

	count_chars:
		move $a0, $s0
		la $a1, Buffer
		li $a2, 1
		count:
			li $v0, 14
			syscall
			addi $t0, $t0, 1
			bnez $v0, count # (if !EOF goto count)
			subi $t0, $t0, 1 # desconsiderando EOF
			jr $ra

	fscanf:
		move $a0, $s0
		la $a1, Buffer
		li $a2, 1

		read:
			li $v0, 14
			syscall
			beqz $v0, return_eof # (if !EOF goto count)
			lb $t0, ($a1) # lê o primeiro dígito do número
			beq $t0, 32, read # verifica se o dígito é um espaço em branco
			li $t1, 0
			to_int:
				subi $t0, $t0, 48
				mul $t1, $t1, 10
				add $t1, $t1, $t0
				
				li $v0, 14
				syscall
				beqz $v0, return_eof # (if !EOF goto count)				
				lb $t0, ($a1) # lê o próximo dígito do número
				beq $t0, 32, save_number # verifica se o dígito é um espaço em branc

				j to_int

			save_number:
				sll $t4, $s2, 2
				add $t4, $t4, $s1
				sw $t1, 0($t4)
				addi $s2, $s2, 1 # reinicializa a variavel do numero lido

				li $t1, 0
				j read

		return_eof:
			jr $ra

		print_array:
			li $t1, 0
			loop:
				beq $s2, $t1, exit 
				sll $t5, $t1, 2 
				add $t5, $t5, $s1 
				lw $t4, 0($t5)  
				print_int($t4)
				print_str(" ")
				addi $t1, $t1, 1 
				j loop
		exit:
			jr $ra

	maior:
		li $t1, 0
		loop1:
			beq $s2, $t1, exit1
			sll $t5, $t1, 2
			add $t5, $t5, $s1
			lw $t4, 0($t5)
			addi $t1, $t1, 1
			bgt $t2, $t4, loop1
			move $t2, $t4
			j loop1
		exit1:
			jr $ra

	menor:
		li $t1, 0
		loop2:
			beq $s2, $t1, exit2
			sll $t5, $t1, 2
			add $t5, $t5, $s1
			lw $t4, 0($t5)
			addi $t1, $t1, 1
			blt $t2, $t4, loop2
			move $t2, $t4
			j loop2
		exit2:
			jr $ra

	impares_pares:
		li $t1, 0
		li $t6, 2
		loop3:
			beq $s2, $t1, exit3
			sll $t5, $t1, 2
			add $t5, $t5, $s1
			lw $t4, 0($t5)
			addi $t1, $t1, 1
			div $t4, $t6
			mflo $t7

			j loop3
		exit3:
			jr $ra
