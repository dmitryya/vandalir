; ModuleID = './test/Juliet/CWE415/good/CWE415_Double_Free__malloc_free_struct_34-good.bc'
source_filename = "ld-temp.o"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct._twoIntsStruct = type { i32, i32 }
%union.CWE415_Double_Free__malloc_free_struct_34_unionType = type { %struct._twoIntsStruct* }

@.str = private unnamed_addr constant [18 x i8] c"Calling good()...\00", align 1
@.str.1 = private unnamed_addr constant [16 x i8] c"Finished good()\00", align 1

; Function Attrs: noinline nounwind optnone uwtable
define internal void @CWE415_Double_Free__malloc_free_struct_34_good() #0 {
  call void @goodG2B()
  call void @goodB2G()
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define internal void @goodG2B() #0 {
  %1 = alloca %struct._twoIntsStruct*, align 8
  %2 = alloca %union.CWE415_Double_Free__malloc_free_struct_34_unionType, align 8
  %3 = alloca %struct._twoIntsStruct*, align 8
  store %struct._twoIntsStruct* null, %struct._twoIntsStruct** %1, align 8
  %4 = call noalias i8* @malloc(i64 800) #4
  %5 = bitcast i8* %4 to %struct._twoIntsStruct*
  store %struct._twoIntsStruct* %5, %struct._twoIntsStruct** %1, align 8
  %6 = load %struct._twoIntsStruct*, %struct._twoIntsStruct** %1, align 8
  %7 = icmp eq %struct._twoIntsStruct* %6, null
  br i1 %7, label %8, label %9

8:                                                ; preds = %0
  call void @exit(i32 -1) #5
  unreachable

9:                                                ; preds = %0
  %10 = load %struct._twoIntsStruct*, %struct._twoIntsStruct** %1, align 8
  %11 = bitcast %union.CWE415_Double_Free__malloc_free_struct_34_unionType* %2 to %struct._twoIntsStruct**
  store %struct._twoIntsStruct* %10, %struct._twoIntsStruct** %11, align 8
  %12 = bitcast %union.CWE415_Double_Free__malloc_free_struct_34_unionType* %2 to %struct._twoIntsStruct**
  %13 = load %struct._twoIntsStruct*, %struct._twoIntsStruct** %12, align 8
  store %struct._twoIntsStruct* %13, %struct._twoIntsStruct** %3, align 8
  %14 = load %struct._twoIntsStruct*, %struct._twoIntsStruct** %3, align 8
  %15 = bitcast %struct._twoIntsStruct* %14 to i8*
  call void @free(i8* %15) #4
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define internal void @goodB2G() #0 {
  %1 = alloca %struct._twoIntsStruct*, align 8
  %2 = alloca %union.CWE415_Double_Free__malloc_free_struct_34_unionType, align 8
  %3 = alloca %struct._twoIntsStruct*, align 8
  store %struct._twoIntsStruct* null, %struct._twoIntsStruct** %1, align 8
  %4 = call noalias i8* @malloc(i64 800) #4
  %5 = bitcast i8* %4 to %struct._twoIntsStruct*
  store %struct._twoIntsStruct* %5, %struct._twoIntsStruct** %1, align 8
  %6 = load %struct._twoIntsStruct*, %struct._twoIntsStruct** %1, align 8
  %7 = icmp eq %struct._twoIntsStruct* %6, null
  br i1 %7, label %8, label %9

8:                                                ; preds = %0
  call void @exit(i32 -1) #5
  unreachable

9:                                                ; preds = %0
  %10 = load %struct._twoIntsStruct*, %struct._twoIntsStruct** %1, align 8
  %11 = bitcast %struct._twoIntsStruct* %10 to i8*
  call void @free(i8* %11) #4
  %12 = load %struct._twoIntsStruct*, %struct._twoIntsStruct** %1, align 8
  %13 = bitcast %union.CWE415_Double_Free__malloc_free_struct_34_unionType* %2 to %struct._twoIntsStruct**
  store %struct._twoIntsStruct* %12, %struct._twoIntsStruct** %13, align 8
  %14 = bitcast %union.CWE415_Double_Free__malloc_free_struct_34_unionType* %2 to %struct._twoIntsStruct**
  %15 = load %struct._twoIntsStruct*, %struct._twoIntsStruct** %14, align 8
  store %struct._twoIntsStruct* %15, %struct._twoIntsStruct** %3, align 8
  ret void
}

; Function Attrs: nounwind
declare dso_local noalias i8* @malloc(i64) #1

; Function Attrs: noreturn nounwind
declare dso_local void @exit(i32) #2

; Function Attrs: nounwind
declare dso_local void @free(i8*) #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @main(i32 %0, i8** %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i8**, align 8
  store i32 0, i32* %3, align 4
  store i32 %0, i32* %4, align 4
  store i8** %1, i8*** %5, align 8
  %6 = call i64 @time(i64* null) #4
  %7 = trunc i64 %6 to i32
  call void @srand(i32 %7) #4
  call void @printLine(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @.str, i64 0, i64 0))
  call void @CWE415_Double_Free__malloc_free_struct_34_good()
  call void @printLine(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.1, i64 0, i64 0))
  ret i32 0
}

; Function Attrs: nounwind
declare dso_local i64 @time(i64*) #1

; Function Attrs: nounwind
declare dso_local void @srand(i32) #1

declare dso_local void @printLine(i8*) #3

attributes #0 = { noinline nounwind optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { noreturn nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind }
attributes #5 = { noreturn nounwind }

!llvm.ident = !{!0}
!llvm.module.flags = !{!1, !2, !3, !4}

!0 = !{!"clang version 10.0.0-4ubuntu1 "}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 1, !"ThinLTO", i32 0}
!3 = !{i32 1, !"EnableSplitLTOUnit", i32 1}
!4 = !{i32 1, !"LTOPostLink", i32 1}