.include "macros.asm"

.data 
    FileInput: .asciiz "C:\\Users\\marco\\Desktop\\UEL\\Comp_Architecture\\Arq2\\matriz.txt"
    FileOutput: .asciiz "C:\\Users\\marco\\Desktop\\UEL\\Comp_Architecture\\Arq2\\matriz_saida.txt"
    buffer: .asciiz " "
    Error: .asciiz "Erro ao abrir o arquivo!\n"
.text

    main:
        jal fopen_read
        move $s0, $v0 # identificador do arquivo de entrada

        li $t7, 32
        calloc($t7, $s1) # aloca memória para as dimensões da matriz em $s1
        li $s2, 0 # contador de dimensões
        li $s3, 0 # qntd linhas
        li $s4, 0 # qntd colunas
        li $s5, 0 # qntd elementos zerados
        jal get_dimensions

        mul $t0, $s3, $s4 # nlin * ncol
        mul $t0, $t0, 4 # (nlin * ncol) * 4 (inteiro)
        calloc($t0, $s1) # aloca memória para a matriz em $s1

        li $t0, 0 # contador de linhas
        li $t1, 0 # contador de colunas
        jal init_matriz
        
        mul $s5, $s5, 2 # qntd elementos zerados * 2 (inteiro) pois temos linha e coluna
        mul $t0, $s5, 4 # (qntd elementos zerados * 2) * 4 (inteiro)
        calloc($t0, $s6) # aloca memória para as posições em $s1

        li $s2, 0 # contador de posições
        jal get_positions

        jal change_matrix

        jal fclose

        # $s1 = matriz
        # $s2 = tamanho 
        # $s3 = linhas
        # $s4 = colunas
        # $s5 = string
        # $s6 = qntd de char na string

        jal fopen_write
        move $s0, $v0 # identificador do arquivo de saída

        li $t7, 1024
        calloc($t7, $s5) # string para ser impressa
        mul $s2, $s3, $s4 # tamanho do vetor a ser convertido
        jal array_to_string

        jal count_char_str

        jal fprintf

        jal fclose
        terminate

    fopen_read:
		la $a0, FileInput # carrega o endereço do arquivo na memória
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
		la $a0, FileOutput
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

    fprintf:
        move $a0, $s0 # file descriptor
        move $a1, $s5 # string to print
        move $a2, $s6 # string length
        li $v0, 15
        syscall
        jr $ra

    get_dimensions:
        move $a0, $s0
		la $a1, buffer
		li $a2, 1
        gets:
            li $v0, 14
            syscall
            beqz $v0, return_eof # (if !EOF goto count)
            lb $t0, ($a1) # lê o primeiro dígito do número
            beq $t0, 32, gets # verifica se o dígito é um espaço em branco
            beq $t0, 10, return_eof # verifica se o dígito é o fim de linha
            beq $t0, 13, return_eof
            li $t1, 0
            to_int:
                subi $t0, $t0, 48
                mul $t1, $t1, 10
                add $t1, $t1, $t0

                li $v0, 14
                syscall
                beqz $v0, save_number # (if EOF goto save_number and return_eof)
                lb $t0, ($a1) # lê o próximo dígito do número
                beq $t0, 32, save_number # verifica se o digito e espaco em branco
                beq $t0, 10, save_number # verifica se o digito e fim de linha
                beq $t0, 13, save_number
                j to_int

            save_number:
                sll $t4, $s2, 2
                add $t4, $t4, $s1
                sw $t1, 0($t4)
                addi $s2, $s2, 1 
                li $t1, 0 # reinicializa a variavel do numero lido
                beq $t0, 10, return_eof # verifica se o digito e fim de linha
                beq $t0, 13, return_eof
                j gets
            return_eof:
                li $t0, 0
                sll $t4, $t0, 2
                add $t4, $t4, $s1
                lw $s3, 0($t4) # linhas
                addi $t0, $t0, 1
                sll $t4, $t0, 2
                add $t4, $t4, $s1
                lw $s4, 0($t4) # colunas
                addi $t0, $t0, 1
                sll $t4, $t0, 2
                add $t4, $t4, $s1 
                lw $s5, 0($t4) # zerados
                jr $ra

    get_positions:
        move $a0, $s0
		la $a1, buffer
		li $a2, 1
        posic:
            li $v0, 14
            syscall
            beqz $v0, return_eof2 # (if !EOF goto count)
            lb $t0, ($a1) # lê o primeiro dígito do número
            beq $t0, 32, posic # verifica se o dígito é um espaço em branco
            beq $t0, 10, posic # verifica se o dígito é o fim de linha
            beq $t0, 13, posic
            li $t1, 0
            to_int2:
                subi $t0, $t0, 48
                mul $t1, $t1, 10
                add $t1, $t1, $t0

                li $v0, 14
                syscall
                beqz $v0, save_number2 # (if EOF goto save_number and return_eof)
                lb $t0, ($a1) # lê o próximo dígito do número
                beq $t0, 32, save_number2 # verifica se o digito e espaco em branco
                beq $t0, 10, save_number2 # verifica se o digito e fim de linha
                beq $t0, 13, save_number2
                j to_int2

            save_number2:
                sll $t4, $s2, 2
                add $t4, $t4, $s6
                sw $t1, 0($t4)
                addi $s2, $s2, 1 
                li $t1, 0 # reinicializa a variavel do numero lido
                j posic
            return_eof2:
                jr $ra

    indice:
		mul $t6, $t0, $s4 # i * ncol
   		add $t6, $t6, $t1 # (i * ncol) + j
   		sll $t6, $t6, 2 # [(i * ncol) + j] * 4 (inteiro)
   		add $t6, $t6, $s1 
   		jr $ra 

    init_matriz:
   		subi $sp, $sp, 4 
   		sw $ra, ($sp)
        l:
            li $t2, 1 # valor default
            jal indice 
            sw $t2, ($t6) # mat[i][j] = aux
            addi $t1, $t1, 1 # j++
            blt $t1, $s4, l # if(j < ncol) goto l
            li $t1, 0 # j = 0
            addi $t0, $t0, 1 # i++
            blt $t0, $s3, l # if(i < nlin) goto l
            li $t0, 0 # i = 0
            lw $ra, ($sp) 
            addi $sp, $sp, 4
            jr $ra

    change_matrix:
        subi $sp, $sp, 4 
   		sw $ra, ($sp)
        li $t3, 0 # iterador vetor de posicoes zeradas 
        c:
            bge $t3, $s5, return # if(t3 >= npos) goto return 
            sll $t4, $t3, 2
            add $t4, $t4, $s6
            lw $t0, 0($t4) # linha da posicao a ser zerada
            addi $t3, $t3, 1
            sll $t4, $t3, 2
            add $t4, $t4, $s6
            lw $t1, 0($t4) # coluna da posicao a ser zerada
            add $t3, $t3, 1 
            jal indice
            li $t4, 0 # valor a ser atribuido
            sw $t4, ($t6) # mat[i][j] = 0
            j c
        return:
            lw $ra, ($sp) 
            addi $sp, $sp, 4
            jr $ra

    count_char_str:
        li $t0, 0 # posicao string
        li $s6, 0 # contador de caracteres
        count:
            sll $t4, $t0, 0
            add $t4, $t4, $s5
            lb $t3, 0($t4) # linha da posicao a ser zerada
            beqz $t3, over
            addi $t0, $t0, 1
            addi $s6, $s6, 1
            j count
        over:
            jr $ra

    array_to_string:
        li $t0, 0 # contador vetor
        li $t1, 0 # contador string
        li $t3, 0 # contador de colunas
        lp:
            beq $t0, $s2, sai 
            beq $t3, $s4, next_line
            sll $t5, $t0, 2
            add $t5, $t5, $s1
            lw $t4, 0($t5)
            addi $t0, $t0, 1
            addi $t3, $t3, 1

            blt $t4, 100, dezena

            centena:
                li $t5, 100
                li $t6, 48
                div $t4, $t5
                mflo $t7

                add $t7, $t7, $t6
                sll $t5, $t1, 0
                add $t5, $t5, $s5
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
                    add $t5, $t5, $s5
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
                add $t5, $t5, $s5
                sb $t7, 0($t5)
                addi $t1, $t1, 1

            unidade:   
                mfhi $t7
                add $t7, $t7, $t6
                sll $t5, $t1, 0
                add $t5, $t5, $s5
                sb $t7, 0($t5)
                addi $t1, $t1, 1

            space:
                li $t6, 32
                sll $t5, $t1, 0
                add $t5, $t5, $s5
                sb $t6, 0($t5)
                addi $t1, $t1, 1
                j lp

            next_line:
                li $t6, 10
                sll $t5, $t1, 0
                add $t5, $t5, $s5
                sb $t6, 0($t5)
                addi $t1, $t1, 1
                li $t3, 0

            j lp
        sai:
            li $t6, 10
            sll $t5, $t1, 0
            add $t5, $t5, $s5
            sb $t6, 0($t5)
            jr $ra