.include "macros.asm"

.data
	Error: .asciiz "Arquivo nao encontrado!\n"
	FilePath: .asciiz "C:\\Users\\marco\\Desktop\\UEL\\Comp_Architecture\\Arq2\\vetor7_3.txt"
	Buffer: .asciiz " "
	string: .space 2048
.text

	main:
		
		jal fopen_read
		move $s0, $v0
		
		li $s7, 2048
		calloc($s7, $s1)
		li $s2, 0 # indice do vetor
		jal fscanf
		print_str("\n Numeros lidos de vetor7_3.txt: ")
		jal print_array
		jal fclose

        print_str("\n\n Informe o indice do vetor que deseja somar +1: ") 
        scan_int($s3)
		subi $s3, $s3, 1
        jal add_one
        
        print_str("\n Novo vetor: ")
        jal print_array
        
		jal array_to_string

        jal fopen_write
        move $s0, $v0

        jal count_char_str

		jal fprintf

        jal fclose
        terminate

    fopen_read:
		la $a0, FilePath
		li $a1, 0 
		li $v0, 13
		syscall
		blez $v0, erro_r # verifica se ocorreu erro ao abrir o arquivo
		jr $ra # retorna com o identificador do arquivo em $v0
		erro_r: 
			la $a0, Error
			li $v0, 4
			syscall
			li $v0, 10
			syscall
        
    fopen_write:
		la $a0, FilePath
		li $a1, 1
		li $v0, 13
		syscall
		blez $v0, erro_w # verifica se ocorreu erro ao abrir o arquivo
		jr $ra # retorna com o identificador do arquivo em $v0
		erro_w: 
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

	fscanf:
		move $a0, $s0
		la $a1, Buffer
		li $a2, 1

		read:
			li $v0, 14
			syscall
			beqz $v0, return_eof # (if !EOF goto count)
			lb $t0, ($a1) # lê o primeiro dígito do número
			beq $t0, 13, read
            beq $t0, 32, read # verifica se o dígito é um espaço em branco
            beq $t0, 10, read # verifica se o dígito é o fim de linha
			li $t1, 0
			bne $t0, 45, to_int # verifica se o dígito é um sinal de negativo
			li $t7, 1 # se for, seta a variavel de sinal para 1
			j read
			to_int:
				subi $t0, $t0, 48
				mul $t1, $t1, 10
				add $t1, $t1, $t0

				li $v0, 14
				syscall
				beqz $v0, save_number # (if EOF goto save_number and return_eof)
				lb $t0, ($a1) # lê o próximo dígito do número
				beq $t0, 13, save_number
				beq $t0, 10, save_number # verifica se o digito e fim de linha
				beq $t0, 32, save_number # verifica se o digito e espaco em branco
				
				j to_int

			save_number:
				sll $t4, $s2, 2
				add $t4, $t4, $s1
				bne $t7, 1, s 
				negativo:
					mul $t1, $t1, -1
				s:
					sw $t1, 0($t4)
					addi $s2, $s2, 1 
				li $t7, 0 # reinicializa a variavel de sinal
				li $t1, 0 # reinicializa a variavel do numero lido
				j read

		return_eof:
			jr $ra

	fprintf:
        move $a0, $s0 # file descriptor
        move $a1, $t2 # string to print
        move $a2, $s6 # string length
        li $v0, 15
        syscall
        jr $ra

    count_char_str:
        li $t0, 0 # posicao string
        li $s6, 0 # contador de caracteres
        count:
            sll $t4, $t0, 0
            add $t4, $t4, $t2
            lb $t3, 0($t4) # linha da posicao a ser zerada
            beqz $t3, over
            addi $t0, $t0, 1
            addi $s6, $s6, 1
            j count
        over:
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

    add_one:
        sll $t4, $s3, 2
        add $t4, $t4, $s1
        lw $t5, 0($t4)
        addi $t5, $t5, 1
        sw $t5, 0($t4)
        jr $ra

	array_to_string:
        li $t0, 0 # contador vetor
        li $t1, 0 # contador string
        la $t2, string
        lp:
            beq $t0, $s2, sai 
            sll $t5, $t0, 2
            add $t5, $t5, $s1
            lw $t4, 0($t5)
            addi $t0, $t0, 1

            blt $t4, 100, dezena

            centena:
                li $t5, 100
                li $t6, 48
                div $t4, $t5
                mflo $t7

                add $t7, $t7, $t6
                sll $t5, $t1, 0
                add $t5, $t5, $t2
                sb $t7, 0($t5)
                addi $t1, $t1, 1

            dezena_especial:
                    li $t5, 10
                    li $t6, 48
                    div $t4, $t5
                    mflo $t7
                    div $t7, $t5
                    mfhi $t7

                    add $t7, $t7, $t6
                    sll $t5, $t1, 0
                    add $t5, $t5, $t2
                    sb $t7, 0($t5)
                    addi $t1, $t1, 1

                    li $t5, 10
                    div $t4, $t5
                    j unidade

            dezena: 
                li $t5, 10
                li $t6, 48
                div $t4, $t5
                blt $t4, 10, unidade
                mflo $t7

                add $t7, $t7, $t6
                sll $t5, $t1, 0
                add $t5, $t5, $t2
                sb $t7, 0($t5)
                addi $t1, $t1, 1

            unidade:   
                mfhi $t7
                add $t7, $t7, $t6
                sll $t5, $t1, 0
                add $t5, $t5, $t2
                sb $t7, 0($t5)
                addi $t1, $t1, 1

            space:
                li $t6, 32
                sll $t5, $t1, 0
                add $t5, $t5, $t2
                sb $t6, 0($t5)
                addi $t1, $t1, 1
            j lp
        sai:
            li $t6, 10
            sll $t5, $t1, 0
            add $t5, $t5, $t2
            sb $t6, 0($t5)
            jr $ra