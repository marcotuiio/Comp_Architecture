.include "macros.asm"

.data 
    File1: .asciiz "C:\\Users\\marco\\Desktop\\UEL\\Comp_Architecture\\Arq2\\palavras1.txt"
    File2: .asciiz "C:\\Users\\marco\\Desktop\\UEL\\Comp_Architecture\\Arq2\\palavras2.txt"
    InputFile1: .space 1024
    InputFile2: .space 1024
    currentWord1: .space 32
    currentWord2: .space 32
.text

    main:
        la $t0, File1 # carrega o endereco de File1 em $t0
        jal fopen_read
        move $s0, $v0 # salva o identificador do arquivo em $s0
        
        la $s1, InputFile1 # carrega o endereco de InputFile1 em $s1
        move $a1, $s1 # carrega o endereco de InputFile1 em $a1
        jal fscanf # le o arquivo
        jal fclose
        
        print_str("Todas as palavras lidas do arquivo 1: \n")
        move $a0, $s1
        li $v0, 4
        syscall

        la $t0, File2 # carrega o endereco de File2 em $t0
        jal fopen_read
        move $s0, $v0 # salva o identificador do arquivo em $s0

        la $s2, InputFile2 # carrega o endereco de InputFile2 em $s2
        move $a1, $s2 # carrega o endereco de InputFile2 em $a1
        jal fscanf # le o arquivo
        jal fclose

        print_str("\n\nTodas as palavras lidas do arquivo 2: \n")
        move $a0, $s2
        li $v0, 4
        syscall

        li $t7, 5 # tamanho minimo
        la $s0, currentWord1 # carrega o endereco de currentWord em $s0
        li $s5, 0 # posicao string
        li $s6, 0 # posicao currentWord
        print_str("\n")
        seleciona_palavra:
            sll $t6, $s5, 0
            add $t6, $t6, $s1
            lb $t3, 0($t6) # linha da posicao a ser zerada
            addi $s5, $s5, 1
            
            beqz $t3, next_word
            beq $t3, 32, next_word # verifica se eh espaco

            sll $t5, $s6, 0
            add $t5, $t5, $s0 
            sb $t3, 0($t5) # salva o caractere na string
            addi $s6, $s6, 1

            j seleciona_palavra
            next_word:
                jal count_char_str
                bge $s3, $t7, busca_palavra # verifica se a palavra tem tamanho minimo
                
                nao_satisfaz:
                    bge $s3, $t7, analise
                    print_str("\nPalavra com tamanho menor que 5: ")
                    move $a0, $s0
                    li $v0, 4
                    syscall
                    j nexttt

                analise: 
                    bnez $v1, nexttt
                    print_str("\n\n-----> Palavra encontrada em ambos os arquivos: ")
                    move $a0, $s0
                    li $v0, 4
                    syscall

                nexttt:
                    print_str("\n")
                    move $a0, $s0
                    jal clean_string
                    li $s6, 0 # posicao currentWord
                    beqz $t3, over_selec
                    j seleciona_palavra

        over_selec:
            terminate

    fopen_read:
		move $a0, $t0 
		li $a1, 0 # somente leitura
		li $v0, 13
		syscall
		blez $v0, erro_r # verifica se ocorreu erro ao abrir o arquivo
		jr $ra # retorna com o identificador do arquivo em $v0
		erro_r: 
			print_str("Erro ao abrir o arquivo!\n")
			li $v0, 10
			syscall
    
    fscanf:
        move $a0, $s0 # carrega o identificador do arquivo em $a0
        la $a2, 1024 # carrega o endereco de MaxSize em $a2
        li $v0, 14
        syscall

	fclose:
		move $a0, $s0
		li $v0, 16
		syscall
		jr $ra

    count_char_str:
        li $t0, 0 # posicao string
        li $s3, 0 # contador de caracteres
        count:
            sll $t5, $t0, 0
            add $t5, $t5, $s0
            lb $t6, 0($t5) 
            beqz $t6, over
            addi $t0, $t0, 1
            addi $s3, $s3, 1
            j count
        over:
            jr $ra

    clean_string:
        li $t8, 0         # inicializa o contador de posição da string        
        cleaning:
            sll $t2, $t8, 0
            add $t2, $t2, $a0
            lb $t1, 0($t2)     # carrega o caractere
            beqz $t1, end_cleaning # termina o loop se o caractere é zero
            sb $zero, 0($t2)   # substitui o caractere por zero
            addi $t8, $t8, 1  # avança para o próximo caractere
            bnez $t1, cleaning    # repete o loop se o próximo caractere não é zero
        end_cleaning:
            jr $ra            # retorna para a função chamadora

    busca_palavra:
        la $s7, currentWord2 # carrega o endereco de currentWord em $s4
        li $t0, 0 # posicao string2
        li $t1, 0 # posicao currentWord2
        seleciona_palavra2:
            sll $t6, $t0, 0
            add $t6, $t6, $s2
            lb $t4, 0($t6) # linha da posicao a ser zerada
            addi $t0, $t0, 1
            
            beqz $t4, next_word2
            beq $t4, 32, next_word2 # verifica se eh espaco

            sll $t5, $t1, 0
            add $t5, $t5, $s7 
            sb $t4, 0($t5) # salva o caractere na string
            addi $t1, $t1, 1

            j seleciona_palavra2
            next_word2:
                jal strcmp
                beqz $v1, analise 
                move $a0, $s7
                jal clean_string
                li $t1, 0 # posicao currentWord
                beqz $t4, over_selec2
                j seleciona_palavra2

            over_selec2:
                j analise

    strcmp:
        print_str("\nComparando: ")
        move $a0, $s0
        li $v0, 4
        syscall
        print_str(" e ")
        move $a0, $s7
        li $v0, 4
        syscall
        li $a1, 0
        li $a2, 0
        li $t5, 0      # inicializa contador de posição na string

        loop_strcmp:
            sll $t8, $a1, 0
            add $t8, $t8, $s0
            lb $t2, 0($t8) # carrega byte da primeira string
            addi $a1, $a1, 1 # avança posição na primeira string

            sll $t9, $a2, 0
            add $t9, $t9, $s7
            lb $t6, 0($t9) # carrega byte da segunda string
            addi $a2, $a2, 1 # avança posição na segunda string

            beqz $t2, end  # se chegar ao final da string, sai do loop
            bne $t2, $t6, dif # se os bytes são diferentes, sai do loop
            j loop_strcmp         # volta ao início do loop
        dif:
            li $v1, 1       # as strings são diferentes
            jr $ra
        end:
            li $v1, 0       # as strings são iguais
            jr $ra