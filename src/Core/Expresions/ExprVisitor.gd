@abstract
extends RefCounted
class_name ExprVisitor

@abstract func visitAssignExpr(expr: Assign)
@abstract func visitBinaryExpr(expr: Binary)
@abstract func visitGroupingExpr(expr: Grouping)
@abstract func visitLiteralExpr(expr: Literal)
@abstract func visitLogicalExpr(expr: Logical)
@abstract func visitUnaryExpr(expr: Unary)
@abstract func visitVariableExpr(expr: Variable)
