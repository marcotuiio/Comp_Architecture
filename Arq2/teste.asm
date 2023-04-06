.include "macros.asm"

.data
	Error: .asciiz "Arquivo nao encontrado!\n"
	FilePath: .asciiz "C:\\Users\\marco\\Desktop\\UEL\\Comp_Architecture\\Arq2\\teste.txt"
	Buffer: .asciiz " "
	vetor: .space 512
.text

	main:
		
		jal fopen
		move $s0, $v0

        jal contagem
        print_str("Contagem: ")
        print_int($t0)

		jal fscanf
        jal fprintf
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

		contagem:
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
			la $a1, vetor
			li $a2, 1024
            li $v0, 14
            syscall
	
			return_eof:
				jr $ra

        fprintf:
            li $v0, 4
            la $a0, vetor
            syscall
            jr $ra