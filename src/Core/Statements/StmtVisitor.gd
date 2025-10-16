@abstract
extends RefCounted
class_name StmtVisitor

@abstract func visitBlockStmt(stmt: Block)
@abstract func visitLoxExpressionStmt(stmt: LoxExpression)
@abstract func visitPrintStmt(stmt: Print)
@abstract func visitVarStmt(stmt: Var)
