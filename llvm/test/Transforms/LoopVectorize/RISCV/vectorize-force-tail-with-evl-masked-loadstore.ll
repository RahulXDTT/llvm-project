; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -passes=loop-vectorize \
; RUN: -force-tail-folding-style=data-with-evl \
; RUN: -prefer-predicate-over-epilogue=predicate-dont-vectorize \
; RUN: -mtriple=riscv64 -mattr=+v -S < %s | FileCheck %s --check-prefix=IF-EVL

; RUN: opt -passes=loop-vectorize \
; RUN: -force-tail-folding-style=none \
; RUN: -prefer-predicate-over-epilogue=predicate-dont-vectorize \
; RUN: -mtriple=riscv64 -mattr=+v -S < %s | FileCheck %s --check-prefix=NO-VP

define void @masked_loadstore(ptr noalias %a, ptr noalias %b, i64 %n) {
; IF-EVL-LABEL: @masked_loadstore(
; IF-EVL-NEXT:  entry:
; IF-EVL-NEXT:    [[TMP0:%.*]] = sub i64 -1, [[N:%.*]]
; IF-EVL-NEXT:    [[TMP1:%.*]] = call i64 @llvm.vscale.i64()
; IF-EVL-NEXT:    [[TMP2:%.*]] = mul nuw i64 [[TMP1]], 4
; IF-EVL-NEXT:    [[TMP3:%.*]] = icmp ult i64 [[TMP0]], [[TMP2]]
; IF-EVL-NEXT:    br i1 [[TMP3]], label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; IF-EVL:       vector.ph:
; IF-EVL-NEXT:    [[TMP4:%.*]] = call i64 @llvm.vscale.i64()
; IF-EVL-NEXT:    [[TMP5:%.*]] = mul nuw i64 [[TMP4]], 4
; IF-EVL-NEXT:    [[TMP6:%.*]] = sub i64 [[TMP5]], 1
; IF-EVL-NEXT:    [[N_RND_UP:%.*]] = add i64 [[N]], [[TMP6]]
; IF-EVL-NEXT:    [[N_MOD_VF:%.*]] = urem i64 [[N_RND_UP]], [[TMP5]]
; IF-EVL-NEXT:    [[N_VEC:%.*]] = sub i64 [[N_RND_UP]], [[N_MOD_VF]]
; IF-EVL-NEXT:    [[TMP7:%.*]] = call i64 @llvm.vscale.i64()
; IF-EVL-NEXT:    [[TMP8:%.*]] = mul nuw i64 [[TMP7]], 4
; IF-EVL-NEXT:    br label [[VECTOR_BODY:%.*]]
; IF-EVL:       vector.body:
; IF-EVL-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; IF-EVL-NEXT:    [[EVL_BASED_IV:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_EVL_NEXT:%.*]], [[VECTOR_BODY]] ]
; IF-EVL-NEXT:    [[TMP9:%.*]] = sub i64 [[N]], [[EVL_BASED_IV]]
; IF-EVL-NEXT:    [[TMP10:%.*]] = call i32 @llvm.experimental.get.vector.length.i64(i64 [[TMP9]], i32 4, i1 true)
; IF-EVL-NEXT:    [[TMP15:%.*]] = getelementptr inbounds i32, ptr [[B:%.*]], i64 [[EVL_BASED_IV]]
; IF-EVL-NEXT:    [[TMP16:%.*]] = getelementptr inbounds i32, ptr [[TMP15]], i32 0
; IF-EVL-NEXT:    [[VP_OP_LOAD:%.*]] = call <vscale x 4 x i32> @llvm.vp.load.nxv4i32.p0(ptr align 4 [[TMP16]], <vscale x 4 x i1> splat (i1 true), i32 [[TMP10]])
; IF-EVL-NEXT:    [[TMP17:%.*]] = icmp ne <vscale x 4 x i32> [[VP_OP_LOAD]], zeroinitializer
; IF-EVL-NEXT:    [[TMP19:%.*]] = getelementptr i32, ptr [[A:%.*]], i64 [[EVL_BASED_IV]]
; IF-EVL-NEXT:    [[TMP20:%.*]] = getelementptr i32, ptr [[TMP19]], i32 0
; IF-EVL-NEXT:    [[VP_OP_LOAD3:%.*]] = call <vscale x 4 x i32> @llvm.vp.load.nxv4i32.p0(ptr align 4 [[TMP20]], <vscale x 4 x i1> [[TMP17]], i32 [[TMP10]])
; IF-EVL-NEXT:    [[VP_OP:%.*]] = add <vscale x 4 x i32> [[VP_OP_LOAD]], [[VP_OP_LOAD3]]
; IF-EVL-NEXT:    call void @llvm.vp.store.nxv4i32.p0(<vscale x 4 x i32> [[VP_OP]], ptr align 4 [[TMP20]], <vscale x 4 x i1> [[TMP17]], i32 [[TMP10]])
; IF-EVL-NEXT:    [[TMP21:%.*]] = zext i32 [[TMP10]] to i64
; IF-EVL-NEXT:    [[INDEX_EVL_NEXT]] = add i64 [[TMP21]], [[EVL_BASED_IV]]
; IF-EVL-NEXT:    [[INDEX_NEXT]] = add i64 [[INDEX]], [[TMP8]]
; IF-EVL-NEXT:    [[TMP22:%.*]] = icmp eq i64 [[INDEX_NEXT]], [[N_VEC]]
; IF-EVL-NEXT:    br i1 [[TMP22]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP0:![0-9]+]]
; IF-EVL:       middle.block:
; IF-EVL-NEXT:    br label [[EXIT:%.*]]
; IF-EVL:       scalar.ph:
; IF-EVL-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i64 [ 0, [[ENTRY:%.*]] ]
; IF-EVL-NEXT:    br label [[FOR_BODY:%.*]]
; IF-EVL:       for.body:
; IF-EVL-NEXT:    [[I_011:%.*]] = phi i64 [ [[INC:%.*]], [[FOR_INC:%.*]] ], [ [[BC_RESUME_VAL]], [[SCALAR_PH]] ]
; IF-EVL-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds i32, ptr [[B]], i64 [[I_011]]
; IF-EVL-NEXT:    [[TMP23:%.*]] = load i32, ptr [[ARRAYIDX]], align 4
; IF-EVL-NEXT:    [[CMP1:%.*]] = icmp ne i32 [[TMP23]], 0
; IF-EVL-NEXT:    br i1 [[CMP1]], label [[IF_THEN:%.*]], label [[FOR_INC]]
; IF-EVL:       if.then:
; IF-EVL-NEXT:    [[ARRAYIDX3:%.*]] = getelementptr inbounds i32, ptr [[A]], i64 [[I_011]]
; IF-EVL-NEXT:    [[TMP24:%.*]] = load i32, ptr [[ARRAYIDX3]], align 4
; IF-EVL-NEXT:    [[ADD:%.*]] = add i32 [[TMP23]], [[TMP24]]
; IF-EVL-NEXT:    store i32 [[ADD]], ptr [[ARRAYIDX3]], align 4
; IF-EVL-NEXT:    br label [[FOR_INC]]
; IF-EVL:       for.inc:
; IF-EVL-NEXT:    [[INC]] = add nuw nsw i64 [[I_011]], 1
; IF-EVL-NEXT:    [[EXITCOND_NOT:%.*]] = icmp eq i64 [[INC]], [[N]]
; IF-EVL-NEXT:    br i1 [[EXITCOND_NOT]], label [[EXIT]], label [[FOR_BODY]], !llvm.loop [[LOOP4:![0-9]+]]
; IF-EVL:       exit:
; IF-EVL-NEXT:    ret void
;
; NO-VP-LABEL: @masked_loadstore(
; NO-VP-NEXT:  entry:
; NO-VP-NEXT:    br label [[FOR_BODY:%.*]]
; NO-VP:       for.body:
; NO-VP-NEXT:    [[I_011:%.*]] = phi i64 [ [[INC:%.*]], [[FOR_INC:%.*]] ], [ 0, [[ENTRY:%.*]] ]
; NO-VP-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds i32, ptr [[B:%.*]], i64 [[I_011]]
; NO-VP-NEXT:    [[TMP0:%.*]] = load i32, ptr [[ARRAYIDX]], align 4
; NO-VP-NEXT:    [[CMP1:%.*]] = icmp ne i32 [[TMP0]], 0
; NO-VP-NEXT:    br i1 [[CMP1]], label [[IF_THEN:%.*]], label [[FOR_INC]]
; NO-VP:       if.then:
; NO-VP-NEXT:    [[ARRAYIDX3:%.*]] = getelementptr inbounds i32, ptr [[A:%.*]], i64 [[I_011]]
; NO-VP-NEXT:    [[TMP1:%.*]] = load i32, ptr [[ARRAYIDX3]], align 4
; NO-VP-NEXT:    [[ADD:%.*]] = add i32 [[TMP0]], [[TMP1]]
; NO-VP-NEXT:    store i32 [[ADD]], ptr [[ARRAYIDX3]], align 4
; NO-VP-NEXT:    br label [[FOR_INC]]
; NO-VP:       for.inc:
; NO-VP-NEXT:    [[INC]] = add nuw nsw i64 [[I_011]], 1
; NO-VP-NEXT:    [[EXITCOND_NOT:%.*]] = icmp eq i64 [[INC]], [[N:%.*]]
; NO-VP-NEXT:    br i1 [[EXITCOND_NOT]], label [[EXIT:%.*]], label [[FOR_BODY]]
; NO-VP:       exit:
; NO-VP-NEXT:    ret void
;
entry:
  br label %for.body

for.body:
  %i.011 = phi i64 [ %inc, %for.inc ], [ 0, %entry ]
  %arrayidx = getelementptr inbounds i32, ptr %b, i64 %i.011
  %0 = load i32, ptr %arrayidx, align 4
  %cmp1 = icmp ne i32 %0, 0
  br i1 %cmp1, label %if.then, label %for.inc

if.then:
  %arrayidx3 = getelementptr inbounds i32, ptr %a, i64 %i.011
  %1 = load i32, ptr %arrayidx3, align 4
  %add = add i32 %0, %1
  store i32 %add, ptr %arrayidx3, align 4
  br label %for.inc

for.inc:
  %inc = add nuw nsw i64 %i.011, 1
  %exitcond.not = icmp eq i64 %inc, %n
  br i1 %exitcond.not, label %exit, label %for.body

exit:
  ret void
}
