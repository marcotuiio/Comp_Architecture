.include "macros.asm"

.data 
    FileInput: .asciiz "C:\\Users\\marco\\Desktop\\UEL\\Comp_Architecture\\Arq2\\input_string.txt"
    FileOutput: .asciiz "C:\\Users\\marco\\Desktop\\UEL\\Comp_Architecture\\Arq2\\vogais_asterisco.txt"
    Input: .space 1024
.text

    main:
        jal fopen_read
        move $s0, $v0 # salva o identificador do arquivo em $s0
        jal fscanf # le o arquivo
        
        jal fclose
        print_str("String lida do arquivo: \n")
        la $s1, Input
        move $a0, $s1
        li $v0, 4
        syscall

        li $t0, 0
        li $t3, 42 # carrega um asterisco em $t3 
        jal asterisco

        jal fopen_write # abre o arquivo
        move $s0, $v0 # salva o identificador do arquivo em $s0

        jal count_char_str

        jal fprintf

        jal fclose

        terminate

    fopen_read:
		la $a0, FileInput
		li $a1, 0 # somente leitura
		li $v0, 13
		syscall
		blez $v0, erro_r # verifica se ocorreu erro ao abrir o arquivo
		jr $ra # retorna com o identificador do arquivo em $v0
		erro_r: 
			print_str("Erro ao abrir o arquivo!\n")
			li $v0, 10
			syscall

    fopen_write:
		la $a0, FileOutput
		li $a1, 1 # somente escrita
		li $v0, 13
		syscall
		blez $v0, erro_w # verifica se ocorreu erro ao abrir o arquivo
		jr $ra # retorna com o identificador do arquivo em $v0
		erro_w: 
			print_str("Erro ao abrir o arquivo!\n")
			li $v0, 10
			syscall

    fscanf:
        move $a0, $s0 # carrega o identificador do arquivo em $a0
        la $a1, Input# carrega o endereco de Input em $a1
        la $a2, 1024 # carrega o endereco de MaxSize em $a2
        li $v0, 14
        syscall

	fclose:
		move $a0, $s0
		li $v0, 16
		syscall
		jr $ra

    fprintf:
        move $a0, $s0 # carrega o identificador do arquivo em $a0 
        move $a1, $s1 # carrega o endereco de Input em $a1
        move $a2, $s2 # carrega o endereco de MaxSize em $a2
        li $v0, 15
        syscall
        jr $ra

    count_char_str:
        li $t0, 0 # posicao string
        li $s2, 0 # contador de caracteres
        count:
            sll $t4, $t0, 0
            add $t4, $t4, $s1
            lb $t3, 0($t4) # linha da posicao a ser zerada
            beqz $t3, over
            addi $t0, $t0, 1
            addi $s2, $s2, 1
            j count
        over:
            jr $ra

    asterisco:
        sll $t1, $t0, 0
        add $t1, $t1, $s1
        lb $t2, 0($t1)
        beqz $t2, end
        beq $t2, 'A', trocar
        beq $t2, 'E', trocar
        beq $t2, 'I', trocar
        beq $t2, 'O', trocar
        beq $t2, 'U', trocar
        beq $t2, 'a', trocar
        beq $t2, 'e', trocar
        beq $t2, 'i', trocar
        beq $t2, 'o', trocar
        beq $t2, 'u', trocar
        j n
        trocar:
            sb $t3, 0($t1)
        n:
            addi $t0, $t0, 1
            j asterisco
        end:
            jr $ra