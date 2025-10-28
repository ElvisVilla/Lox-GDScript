@abstract
extends RefCounted
class_name Stmt

# Abstract method - should be overridden by subclasses
@abstract func accept(visitor: ExprVisitor) -> Variant
