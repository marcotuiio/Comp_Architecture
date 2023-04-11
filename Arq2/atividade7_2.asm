.include "macros.asm"

.data 
    FilePath: .asciiz "C:\\Users\\marco\\Desktop\\UEL\\Comp_Architecture\\Arq2\\vogais_asterisco.txt"
    Input: .space 1023
    MaxSize: .word 1024
.text

    main:
        print_str("Digite uma string: \n")
        la $s1, Input # carrega o endereco de Input em $s1
        lw $s2, MaxSize # carrega o endereco de MaxSize em $s2 
        scan_str($s1, $s2) # le a string

        li $t0, 0
        li $t3, 42 # carrega um asterisco em $t3 
        jal asterisco

        jal fopen # abre o arquivo
        move $s0, $v0 # salva o identificador do arquivo em $s0

        jal fprintf

        jal fclose

        terminate

    fopen:
		la $a0, FilePath
		li $a1, 1 # somente leitura
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

    fprintf:
        move $a0, $s0
        move $a1, $s1
        move $a2, $s2
        li $v0, 15
        syscall
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