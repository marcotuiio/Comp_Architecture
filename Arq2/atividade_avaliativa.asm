.data
    dimensaoString: .asciiz "\nInforme a dimensão da matriz quadrada (maior que 1 menor que 6): "
    invalidoString1: .asciiz "\nNão é permitida dimensão menor que 2, encerrando programa"
    avisoString2: .asciiz "\nDimensão informada maior que 5, fixando dimensão em 5\n"
    insereString: .asciiz "Insira o valor de Mat["
    insereString2: .asciiz "]["
    insereString3: .asciiz "]: "
    avisoPar: .asciiz "\nSomente valores pares na matriz, produto impossível"
    avisoImpar: .asciiz "\nSomente valores ímpares na matriz, produto impossível"
    maiorString: .asciiz "\nO maior valor par é: "
    menorString: .asciiz "\nO menor valor ímpar é: "
    produtoString: .asciiz "\nO produto do maior par com menor impar é: "
    linhasString: .asciiz "\nA soma das linhas em que estão esses elementos é: "
    naLinhaString: .asciiz " na linha "
    spaceString: .asciiz " "
    skipLine: .asciiz "\n"
.text

    main:
        la $a0, dimensaoString
        li $v0, 4
        syscall
        li $v0, 5
        syscall
        move $s1, $v0 # dimensao digitada armazenada em $s1

        verifica_dimensao:
            blt $s1, 2, invalido_menor
            ble $s1, 5, aprovado
            li $s1, 5
            la $a0, avisoString2
            li $v0, 4
            syscall

        aprovado:
            la $a0, skipLine
            li $v0, 4
            syscall
            # alocação 
            mul $s2, $s1, $s1 # quantidade de elementos na matriz
            mul $s2, $s2, 4 # quantidade de bytes que devem ser alocados
            li $v0, 9
            move $a0, $s2
            syscall
            move $s0, $v0 # endereço alocado para matriz em $s0
            
            jal le_mat

            la $a0, skipLine
            li $v0, 4
            syscall
            jal escreve_mat

            li $t8, 0 # contador par
            li $t9, 0 # contador impar
            li $s4, 9999 # armazenar menor elemento impar
            li $s5, -9999 # armazenar maior elemento par
            li $s6, 2 # divisor
            jal getValues

            beqz $t8, sem_par
            beqz $t9, sem_impar

            la $a0, menorString
            li $v0, 4
            syscall
            move $a0, $s4
            li $v0 1
            syscall
            la $a0, naLinhaString
            li $v0, 4
            syscall
            addi $a0, $a3, 1
            li $v0, 1
            syscall

            la $a0, maiorString
            li $v0, 4
            syscall
            move $a0, $s5
            li $v0 1
            syscall
            la $a0, naLinhaString
            li $v0, 4
            syscall
            addi $a0, $a2, 1
            li $v0, 1
            syscall

            la $a0, produtoString
            li $v0, 4
            syscall
            mul $a0, $s4, $s5
            li $v0, 1
            syscall

            la $a0, linhasString
            li $v0, 4
            syscall
            add $a0, $a2, $a3
            addi $a0, $a0, 2
            li $v0, 1
            syscall

            li $v0 10
            syscall

    sem_par:
        la $a0, avisoPar
        li $v0, 4
        syscall
        li $v0, 10
        syscall

    sem_impar:
        la $a0, avisoImpar
        li $v0, 4
        syscall
        li $v0, 10
        syscall

    invalido_menor:
        la $a0, invalidoString1
        li $v0, 4
        syscall 
        li $v0, 10
        syscall

    indice: 
        mul $s3, $t0, $s1 # i * ncol
   		add $s3, $s3, $t1 # (i * ncol) + j
   		sll $s3, $s3, 2 # [(i * ncol) + j] * 4 (inteiro)
   		add $s3, $s3, $s0 # Soma o endereco base de mat
   		jr $ra # Retorna para o caller
        
    le_mat:
   		subi $sp, $sp, 4 # Espaco para 1 item na pilha
   		sw $ra, ($sp) # Salva o retorno para a main
        l:
            la $a0, insereString
            li $v0, 4
            syscall
            addi $a0, $t0, 1 # Valor de i para impressao
            li $v0, 1 # Codigo de impressao de inteiro
            syscall # Imprime i
            la $a0, insereString2
            li $v0, 4
            syscall
            addi $a0, $t1, 1 # Valor de j para impressao
            li $v0, 1 # Codigo de impressao de inteiro
            syscall # Imprime j
            la $a0, insereString3
            li $v0, 4
            syscall
            li $v0, 5 # Codigo de leitura de inteiro
            syscall # Leitura do valor (retorna em $v0)
            move $t2, $v0 # aux = valor lido
            next_read:
                jal indice # Calcula o endereco de mat[i][j]
                sw $t2, ($s3) # mat[i][j] = aux
                addi $t1, $t1, 1 # j++
                blt $t1, $s1, l # if(j < ncol) goto l
                li $t1, 0 # j = 0
                addi $t0, $t0, 1 # i++
                blt $t0, $s1, l # if(i < nlin) goto l
                li $t0, 0 # i = 0
                lw $ra, ($sp) # Recupera o retorno para a main
                addi $sp, $sp, 4 # Libera o espaco na pilha
                jr $ra # Retorna para a main

    escreve_mat:
   		mul $t6, $s1, $s1
        li $t5, 0
        li $t7, 0
        loop_print:	
                beq $t6, $t5, exit_print  # Se tamanho máximo do vetor ja foi alcan�ado, encerrar
                sll $t3, $t5, 2  # Reg temp $t1 = 4*i (indice atual do vetor)
                add $t3, $t3, $s0  # Carregando em $t1 = endere�o de vetor[i] 
                lw $a0, 0($t3)  # $a0 = valor de vetor[i]
                li $v0, 1  # Informando que o syscall deve printar char
                syscall
                la $a0, spaceString
                li $v0, 4
                syscall
                addi $t5, $t5, 1  # Atualizando i = i+1
                addi $t7, $t7, 1
                bne $t7, $s1, loop_print
                la $a0, skipLine
                li $v0, 4
                syscall
                li $t7, 0
                j loop_print
            exit_print:
                jr $ra

    getValues:
		subi $sp, $sp, 4 # Espaco para 1 item na pilha
   		sw $ra, ($sp) # Salva o retorno para a main
        gv:
            jal indice # Calcula o endereco de mat[i][j]
            lw $a0, ($s3) # valor em mat[i][j]

            div $a0, $s6  # divisao do valor atual por 2
            mfhi $s7  # resto da div em $s7

            beqz $s7, par_case

            impar_case:
                addi $t8, $t8, 1
                bgt $a0, $s4, next_value
                move $s4, $a0
                move $a3, $t0 #guardando linha do menor impar
                j next_value

            par_case:
                addi $t9, $t9, 1
                blt $a0, $s5, next_value
                move $s5, $a0
                move $a2, $t0 # guardando linha do maior par

            next_value:
                addi $t1, $t1, 1 # j++
                blt $t1, $s1, gv # if(j < ncol) goto e
                li $t1, 0 # j = 0
                addi $t0, $t0, 1 # i++
                blt $t0, $s1, gv # if(i < nlin) goto e
                li $t0, 0 # i = 0
                lw $ra, ($sp) # Recupera o retorno para a main
                addi $sp, $sp, 4 # Libera o espa�o na pilha
                jr $ra # Retorna para a main