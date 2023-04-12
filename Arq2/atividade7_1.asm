.include "macros.asm"

.data 
    FilePath: .asciiz "C:\\Users\\marco\\Desktop\\UEL\\Comp_Architecture\\Arq2\\primos_gemeos.txt"
    string: .space 2048
.text

    main:
        print_str("Informe N para saber os primos gemeos no intervalo 1-N: ")
        scan_int($s1)

        li $s7, 2048
        calloc($s7, $s2) # aloca memoria para o array de primos
        li $s3, 0
        jal todos_primos
        # jal print_array1

        calloc($s7, $s4) # aloca memoria para o array de primos gemeos
        li $s5, 0
        jal primos_gemeos
        jal print_array2

        jal array_to_string

        jal fopen
		move $s0, $v0
		
        jal fprintf

        jal fclose
        terminate

   	fopen:
		la $a0, FilePath
		li $a1, 1 # somente escrita
		li $v0, 13
		syscall
		blez $v0, erro # verifica se ocorreu erro ao abrir o arquivo
		jr $ra # retorna com o identificador do arquivo em $v0
		erro: 
			print_str("Erro ao abrir o arquivo!\n")
			li $v0, 10
			syscall

	fclose:
		move $a0, $s0
		li $v0, 16
		syscall
		jr $ra

    todos_primos:
        li $t0, 2 
        sll $t4, $s3, 2 
        add $t4, $t4, $s2
        sw $t0, 0($t4)
        addi $s3, $s3, 1

        li $t0, 3
        sll $t4, $s3, 2 
        add $t4, $t4, $s2
        sw $t0, 0($t4)
        addi $s3, $s3, 1

        li $t0, 5  # numero inicial a ser testado que funciona nesse processo
        li $t1, 2  # divisor
        subi $t2, $t0, 1 # limite do loop
        primo: 
            bgt $t0, $s1, fim
            bge $t1, $t2, next
            div $t0, $t1 # n atual / divisor
            mfhi $t3 # resto da divisao
            beqz $t3, next # se resto for zero, nao eh primo
            addi $t1, $t1, 1 # proximo divisor
            bne $t1, $t2, primo
            salvar:
                sll $t4, $s3, 2 
                add $t4, $t4, $s2
                sw $t0, 0($t4)
                addi $s3, $s3, 1 
            next:
                addi $t0, $t0, 1 # proximo numero a ser testado
                li $t1, 2 # divisor
                sub $t2, $t0, 1 # limite do loop 
                j primo
        fim:
            jr $ra

    primos_gemeos:
        li $t0, 0
        pg:
            bgt $t0, $s3, f

            sll $t4, $t0, 2
            add $t4, $t4, $s2
            lw $t1, 0($t4)
            addi $t0, $t0, 1
            sll $t4, $t0, 2
            add $t4, $t4, $s2
            lw $t2, 0($t4)

            add $t3, $t1, 2 # primo atual + 2
            bne $t3, $t2, pg
            eh_pg:
                sll $t4, $s5, 2
                add $t4, $t4, $s4
                sw $t1, 0($t4)
                addi $s5, $s5, 1
                sll $t4, $s5, 2
                add $t4, $t4, $s4
                sw $t2, 0($t4)
                addi $s5, $s5, 1
            j pg
        f:
            jr $ra

    fprintf:
        move $a0, $s0 # file descriptor
        move $a1, $t2 # string to print
        li $a2, 2048 # string length
        li $v0, 15
        syscall
        jr $ra

    array_to_string:
        li $t0, 0 # contador vetor
        li $t1, 0 # contador string
        la $t2, string
        lp:
            beq $t0, $s5, sai 
            sll $t5, $t0, 2
            add $t5, $t5, $s4
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

            li $t5, 2
            div $t0, $t5
            mfhi $t7
            bnez $t7, lp
            next_line:
                li $t6, 10
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

     print_array1:
        li $t1, 0
        l1:
            beq $s3, $t1, e1
            sll $t5, $t1, 2 
            add $t5, $t5, $s2
            lw $t4, 0($t5)  
            print_int($t4)
            print_str(" ")
            addi $t1, $t1, 1 
            j l1
		e1:
			jr $ra

    print_array2:
        li $t1, 0
        l2:
            beq $s5, $t1, e2
            sll $t5, $t1, 2 
            add $t5, $t5, $s4
            lw $t4, 0($t5)  
            print_int($t4)
            print_str(" ")
            addi $t1, $t1, 1 
            j l2
		e2:
			jr $ra
