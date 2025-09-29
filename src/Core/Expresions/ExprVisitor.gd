@abstract
extends RefCounted
class_name ExprVisitor

@abstract func visitBinaryExpr(expr: Binary)
@abstract func visitGroupingExpr(expr: Grouping)
@abstract func visitLiteralExpr(expr: Literal)
@abstract func visitUnaryExpr(expr: Unary)
