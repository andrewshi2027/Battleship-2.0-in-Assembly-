.data
space: .asciiz " "    # Space character for printing between numbers
newline: .asciiz "\n" # Newline character
extra_newline: .asciiz "\n\n" # Extra newline at end

.text
.globl zeroOut 
.globl place_tile 
.globl printBoard 
.globl placePieceOnBoard 
.globl test_fit 



# Function: zeroOut
# Arguments: None
# Returns: void
zeroOut:
    # Function prologue
    addi $sp, $sp, -8 
    sw $ra, 4($sp)

    # Initialize variables
    la $t0, board               # Load address of board
    lw $t1, board_width         # Load number of columns
    lw $t2, board_height        # Load number of rows
    li $t3, 0                   # index = 0

zeroOut_outer: 
    bge $t3, $t2, zero_done     # if row index >= board_height, exit outer loop
    li $t4, 0                   # column index = 0

zeroOut_inner: 
    bge $t4, $t1, next_row      # If all columns are done, go next row
    mul $t5, $t3, $t1           # row offset = row index * number of columns
    add $t6, $t5, $t4           # array index = row offset + column index
    add $t7, $t0, $t6           # memory address of board element
    sb $0, 0($t7)               # Set board[index] to 0

    addiu $t4, $t4, 1           # column index + 1
    j zeroOut_inner             # Jump back to process the next column

next_row:
    addi $t3, $t3, 1            # Increment Row Index
    j zeroOut_outer             # Continue outer loop

zero_done:
    # Function epilogue
    lw $ra, 4($sp)              # Restore stack address 
    addiu $sp, $sp, 8           # Deallocate stack space
    jr $ra                      # Return





# Function: placePieceOnBoard
# Arguments: 
#   $a0 - address of piece struct
#   $a1 - ship_num
placePieceOnBoard:
    # Function prologue
    addiu $sp, $sp, -8
    sw $ra, 4($sp)
    
    # Load piece fields
    lw $s3, 0($a0)              # Load type
    move $s1, $a1               # Load ship_num
    lw $s4, 4($a0)              # Load orientation
    lw $s5, 8($a0)              # Load row location
    lw $s6, 12($a0)             # Load col location

    # Return values
    li $t1, 0               
    li $t2, 1
    li $t3, 2
    li $t4, 3

    # First switch on type
    li $t0, 1
    beq $s3, $t0, piece_square
    li $t0, 2
    beq $s3, $t0, piece_line
    li $t0, 3
    beq $s3, $t0, piece_reverse_z
    li $t0, 4
    beq $s3, $t0, piece_L
    li $t0, 5
    beq $s3, $t0, piece_z
    li $t0, 6
    beq $s3, $t0, piece_reverse_L
    li $t0, 7
    beq $s3, $t0, piece_T
    j piece_done       # Invalid type

place_success:
    jr $ra

place_occupied:
    jal zeroOut
    jr $ra

place_out:
    jal zeroOut
    jr $ra

place_occ_out:
    jal zeroOut
    jr $ra

piece_done:

    move $v0, $s2

    beq $v0, $t1, place_success       # Return 0
    beq $v0, $t2, place_occupied      # Return 1
    beq $v0, $t3, place_out           # Return 2
    beq $v0, $t4, place_occ_out       # Return 3

    lw $ra, 4($sp)
    addiu $sp, $sp, 8
    jr $ra




# Function: printBoard
# Arguments: None (uses global variables)
# Returns: void
# Uses global variables: board (char[]), board_width (int), board_height (int)

printBoard:
    # Function prologue
    addiu $sp, $sp, -8          # Allocate stack space
    sw $ra, 4($sp)              # Save return address

    #Initialize variables
    la $t0, board               # Load address of board
    lw $t1, board_width         # Load number of columns
    lw $t2, board_height        # Load number of rows
    li $t3, 0                   # row index = 0

printBoard_outer:
    bge $t3, $t2, done          # if row index >= board_height, exit outer loop
    li $t4, 0                   # column index = 0

printBoard_inner:
    bge $t4, $t1, printBoard_next_row      
    mul $t5, $t3, $t1           # row offset = row index * number of columns
    add $t6, $t5, $t4           # array index = row offset + column index
    add $t7, $t0, $t6           # memory address of board element
    lb $a0, 0($t7)              # Load current board element
    li $v0, 11                  # Set syscall code for printing character
    addi $a0, $a0, '0'          # Convert number to ASCII character
    syscall                     # Print character
    li $v0, 11                  # Set syscall code for printing space
    li $a0, ' '                 # Space character
    syscall                     # Print the space

    addi $t4, $t4, 1            # column index + 1
    j printBoard_inner          # Jump back to process the next column

printBoard_next_row:
    li $v0, 11                  # Set syscall code for printing newline
    li $a0, '\n'                # Load newline character
    syscall                     # Print the space
    addiu $t3, $t3, 1           # Increment row index
    j printBoard_outer          # Jump back to process the next row

done:
    # Function epilogue
    lw $ra, 4($sp)              # Restore return address
    addiu $sp, $sp, 8           # Deallocate Stack Space
    jr $ra                      # Return





# Function: place_tile
# Arguments: 
#   $a0 - row
#   $a1 - col
#   $a2 - value
# Returns:
#   $v0 - 0 if successful, 1 if occupied, 2 if out of bounds
# Uses global variables: board (char[]), board_width (int), board_height (int)

place_tile:
    # Check if row or column is out of bounds
    lw $t0, board_width         # Load board_width
    lw $t1, board_height        # Load board_height
    bge $a0, $t1, p_out           # If row >= board_height
    bge $a1, $t0, p_out           # If column >= board_width

    # Calculate index in row-major order
    mul $t2, $a0, $t0           # t2 = row * board_width
    add $t2, $t2, $a1           # t2 = row * board_width + column
    la $t3, board               # Load base address of board
    add $t3, $t3, $t2           # t3 = address of board[index]

    # Check if cell is occupied
    lb $t4, 0($t3)              # Load board[index]
    bne $t4, $0, p_occupied       # If board[index] != 0

    # Place value on the board
    sb $a2, 0($t3)              # Set board[index] = value
    li $v0, 0                   # Return 0
    jr $ra

p_occupied:
    li $v0, 1                   # Return 1 (occupied)
    jr $ra

p_out: 
    li $v0, 2                   # Return 2 (out of bounds)
    jr $ra





# Function: test_fit
# Arguments: 
#   $a0 - address of piece array (5 pieces)
test_fit:
    # Function prologue
    jr $ra





T_orientation4:
    # Study the other T orientations in skeleton.asm to understand how to write this label/subroutine
    move $a0, $s5               # row
    move $a1, $s6               # col
    move $a2, $s1
    jal place_tile              # Place center tile
    or $s2, $s2, $v0

    move $a0, $s5
    addi $a0, $a0, -1           # row - 1
    move $a1, $s6               # col
    move $a2, $s1
    jal place_tile              # Place upper tile
    or $s2, $s2, $v0

    move $a0, $s5
    addi $a0, $a0, 1            # row + 1
    move $a1, $s6               # col
    move $a2, $s1
    jal place_tile              # Place lower tile
    or $s2, $s2, $v0

    move $a0, $s5               # row
    addi $a1, $a1, 1            # col + 1
    move $a2, $s1
    jal place_tile              # Place right tile
    or $s2, $s2, $v0

    j piece_done

.include "skeleton.asm"