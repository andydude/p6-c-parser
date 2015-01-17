use v6;
module C::AST::Ops;

enum OpKind is export <
    postinc
    postdec
    preinc
    predec
    preneg
    prepos
    add
    and
    bitand
    bitnot
    bitor
    bitshiftl
    bitshiftr
    bitxor
    deref
    div
    iseq
    isge
    isgt
    isle
    islt
    isne
    mod
    mul
    not
    or
    ref
    sub
    assign
    assign_mul
    assign_div
    assign_mod
    assign_add
    assign_sub
    assign_bitshiftl
    assign_bitshiftr
    assign_bitand
    assign_bitxor
    assign_bitor
    alignas_expr
    alignas_type
    alignof_type
    array_selector
    break_stmt
    call
    cast
    cast_initializer_list
    compound_literal
    compound_stmt
    continue_stmt
    direct_selector
    do_while_stmt
    for_declaration
    for_stmt
    generic_case
    generic_default
    generic_expr
    goto_stmt
    if_expr
    if_stmt
    indirect_goto_stmt
    indirect_selector
    initializer
    initializer_list
    labeled_stmt
    parameter
    parameter_type_list
    return_stmt
    sizeof_expr
    sizeof_type
    switch_case
    switch_default
    switch_stmt
    while_stmt
    cpp_define
    cpp_else
    cpp_elseif
    cpp_endif
    cpp_if
    cpp_ifdef
    cpp_ifndef
    cpp_include
    cpp_line
    cpp_pragma
    c99_pragma
>;

enum TyKind is export <
    attribute 
    apple_block_declarator
    apple_block_type
    apple_block_expr
    apple_block_var
    array_declarator
    array_designator
    array_type
    atomic_type
    declaration
    direct_declarator
    direct_type
    enum_decl
    enum_type
    enumerator
    fixed_length_array_designator
    fixed_length_array_type
    function_declaration
    function_declarator
    function_designator
    function_type
    init_declarator
    parameter_declaration
    pointer_declarator
    pointer_type
    struct_bit_declarator
    struct_declaration
    struct_declarator
    struct_designator
    struct_type
    static_assert_declaration
    typeof_expr
    union_decl
    union_type
    variable_length_array_designator
    variable_length_array_type
    variably_modified_array_designator
    variably_modified_array_type
>;

enum Spec is export < 
    auto
    char
    const
    double
    enum_spec
    extern
    float
    inline
    int
    long
    register
    restrict 
    short
    signed
    static
    struct
    typedef
    union
    unsigned
    void
    volatile
    atomic
    bool
    char16
    char32
    complex
    long_double
    long_long
    noreturn
    signed_char
    thread_local
    unsigned_char
    unsigned_int
    unsigned_long
    unsigned_long_long
    unsigned_short
    wchar
>;
