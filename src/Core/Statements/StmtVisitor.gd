@abstract
extends RefCounted
class_name StmtVisitor

@abstract func visitBlockStmt(stmt: Block)
@abstract func visitLoxExpressionStmt(stmt: LoxExpression)
@abstract func visitFunctionStmt(stmt: Function)
@abstract func visitIfStmt(stmt: If)
@abstract func visitPrintStmt(stmt: Print)
@abstract func visitReturnStmt(stmt: Return)
@abstract func visitVarStmt(stmt: Var)
@abstract func visitWhileStmt(stmt: While)
