import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/brand.dart';
import '../core/controller.dart';
import '../domain/engines.dart';
import '../ui/common.dart';
import '../ui/pet.dart';

class PuzzleScreen extends ConsumerStatefulWidget {
  final String id;
  const PuzzleScreen({super.key,required this.id});
  @override ConsumerState<PuzzleScreen> createState()=>_PuzzleScreenState();
}
class _PuzzleScreenState extends ConsumerState<PuzzleScreen> {
  List<String> answer=[];
  String feedback='';
  bool busy=false;
  @override Widget build(BuildContext context) {
    final app=ref.watch(controllerProvider);
    final p=app.content.find('puzzles',widget.id);
    if(p==null) return const PageShell(title:'Puzzle box',child:Center(child:Text('This puzzle is unavailable. Try another from our box.')));
    final count=(p['answer'] as List).length;
    final order=count>1;
    final spatial=p['engine']=='spatial';
    return PageShell(title:p['title'],child:ListView(padding:const EdgeInsets.all(24),children:[
      SizedBox(height:150,child:PetView(color:app.world.color,outfit:app.world.outfit,reducedMotion:app.world.reducedMotion)),
      Paper(color:Brand.mint,child:Text(p['prompt'],textAlign:TextAlign.center,style:Theme.of(context).textTheme.titleLarge)),const SizedBox(height:20),
      if(p['display']!=null) Padding(padding:const EdgeInsets.all(16),child:Text(p['display'],textAlign:TextAlign.center,style:const TextStyle(fontSize:36,letterSpacing:5))),
      if(order) ...[Text(spatial?'Build the bridge from left to right':'Tap in order, one at a time',textAlign:TextAlign.center),const SizedBox(height:12),Wrap(alignment:WrapAlignment.center,spacing:8,children:List.generate(count,(i)=>Container(constraints:const BoxConstraints(minWidth:60,minHeight:64),padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:i<answer.length?Brand.gold:Colors.white,borderRadius:BorderRadius.circular(spatial?8:18),border:Border.all(color:Brand.sage)),child:Text(i<answer.length?answer[i]:'${i+1}',textAlign:TextAlign.center,style:const TextStyle(fontSize:24))))),const SizedBox(height:20)],
      Wrap(alignment:WrapAlignment.center,spacing:12,runSpacing:12,children:(p['options'] as List).cast<String>().map((option)=>FilledButton.tonal(style:FilledButton.styleFrom(backgroundColor:!order&&answer.contains(option)?Brand.gold:Brand.sky,foregroundColor:Brand.ink,minimumSize:const Size(110,80)),onPressed:busy?null:()=>setState(() { feedback=''; if(order) { if(answer.length<count) answer.add(option); } else {answer=[option];} }),child:Text(option,style:const TextStyle(fontSize:24)))).toList()),
      const SizedBox(height:16),Text(feedback,textAlign:TextAlign.center,style:const TextStyle(fontSize:18,color:Brand.ink)),
      const SizedBox(height:16),FilledButton(onPressed:busy||answer.length!=count?null:() async {
        if(!PuzzleEngine().check(p,answer)) {setState(()=>feedback=p['hint']??'Let’s look again together. There’s no hurry.');return;}
        setState(()=>busy=true);
        final ok=await app.completePuzzle(p);
        if(ok&&context.mounted) await showReward(context,'We figured it out!','Our ${p['topic']} belongs in the memory book. Your explorer hat is ready.');
        if(mounted)setState(()=>busy=false);
      },child:Text(busy?'Keeping our memory…':'Let’s try it')),
      TextButton(onPressed:busy?null:()=>setState(() {answer=[];feedback='';}),child:const Text('Try a new arrangement')),
    ]));
  }
}
