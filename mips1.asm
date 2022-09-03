#### ATIVIDADE MIPS1

# - EQUIVALENTE EM C:
# int result = 0;
# int k = 1;
# while (k <= 20) {
#     result = (4*k + 2) + result;
#     k++;
# }

### REG $s0 ESTARÁ COM RESULTADO FINAL
Main:
	addi $t0, $zero, 1  # $t0 = k = 1
	Loop: 
		beq $t0, 21, Exit   # Se valor de k = 20, fim do loop   
		sll $t1, $t0, 2     # Multiplicando k*2^2 e armazenando no reg de resultado temporário $t1
		addi $t1, $t1, 2    # Somando conteúdo do reg temp $t1 e armazenando nele mesmo
		add $s0, $t1, $s0 	# Armazenando e somando resultado dessa iteração atual com anteriores em $s0	
		addi $t0, $t0, 1    # Somando k+1 e armazenando no reg temp $t0 
		j Loop  			# Repetindo loop
	Exit: # Fim do loop	