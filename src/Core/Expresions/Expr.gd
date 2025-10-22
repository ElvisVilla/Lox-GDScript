@abstract
extends RefCounted
class_name Expr

# Abstract method - should be overridden by subclasses
@abstract func accept(visitor: ExprVisitor) -> Variant

