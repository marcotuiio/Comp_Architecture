.include "macros.asm"

.data 
    list: .word 12, 0, 0 # word size, number of elements, head
    node: .word 12, 0, 0 # word size, info, next 
.text

    main:
        print_str("Linked list in MIPS\n")

        la $s0, list # load address of list
        jal create_list # list address in $s1

        la $s2, node # load address of node      
        
        li $t0, 9 # flag
        loop:
            beqz $t0, end # if flag == 1, end
            jal menu
            beq $t0, 1, create_node
            beq $t0, 2, print_list
            beq $t0, 3, delete_node
            beq $t0, 4, print_size
            j loop
        end:
            terminate
    
    create_list:
        lw $a0, 0($s0) # load word size
        calloc($a0, $s1)
        jr $ra

    create_node:
        lw $a0, 0($s2) # load word size
        calloc($a0, $s3)
        print_str("\nEnter info to add: ")
        scan_int($t2)
        li $t7, 0
        sw $t2, 4($s3) # node->info = info
        sw $t7, 8($s3) # node->next = null

        lw $t1, 8($s0) # load head
        beqz $t1, first_node # if head == null, first_node

        traverse:
            lw $t2, 8($t1) # load next
            beqz $t2, save_node # if next == null, plus
            next_node:
                move $t1, $t2 # previous = next
                j traverse
            save_node:
                sw $s3, 8($t1) # previous->next = node
                j plus

        first_node:
            sw $s3, 8($s0) # head = node
        plus:
            lw $t2, 4($s0) # load size
            addi $t2, $t2, 1 # size++
            sw $t2, 4($s0) # list->size = size
        j loop

    print_list:
        lw $t2, 8($s0) # load head
        beqz $t2, loop # if head == null, loop
        print_str("\nList: ")
        print_loop:
            lw $t3, 4($t2) # load info
            print_int($t3)
            print_str(" ")
            lw $t2, 8($t2) # load next
            bnez $t2, print_loop
        print_str("\n")
        j loop

    delete_node:
        print_str("\nEnter info to be deleted: ")
        scan_int($t2)
        lw $t1, 8($s0) # load head
        beqz $t1, loop # if head == null, loop
        remove_loop:
            lw $t3, 4($t1) # load current info
            beq $t2, $t3, remove
            move $t4, $t1 # save previous
            lw $t1, 8($t1) # load next
            bnez $t1, remove_loop
            print_str("\nInfo not found\n")
            j loop
            remove:
                print_str("\nNode found: ")
                print_int($t3)
                # t1 = current to be removed
                # t4 = previous
                lw $t5, 8($s0) # load head
                bne $t1, $t5, not_head # if current == head, remove_head
                if_head:
                    lw $t5, 8($t1) # load next
                    sw $t5, 8($s0) # head = next
                    j minus
                not_head:    
                    lw $t5, 8($t1) # load next
                    sw $t5, 8($t4) # previous->next = next
                minus:
                    lw $t1, 4($s0) # load word size
                    subi $t1, $t1, 1
                    sw $t1, 4($s0) # list->size--
                print_str("\nNode removed\n")
                j loop

    print_size:
        lw $t2, 4($s0) # load size
        print_str("\nSize: ")
        print_int($t2)
        print_str("\n")
        j loop

    menu:
        print_str("\n1. Add node\n")
        print_str("2. Print list\n")
        print_str("3. Delete node\n")
        print_str("4. List size\n")
        print_str("0. Exit\n")
        print_str(">> Enter option: ")
        scan_int($t0)
        jr $ra