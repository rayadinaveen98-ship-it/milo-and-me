import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/brand.dart';
import '../core/controller.dart';
import '../domain/models.dart';
import '../domain/engines.dart';
import '../ui/common.dart';
import '../ui/pet.dart';

class WardrobeScreen extends ConsumerWidget {
  const WardrobeScreen({super.key});
  @override Widget build(BuildContext context,WidgetRef ref) {
    final app=ref.watch(controllerProvider), w=app.world;
    const items={'none':['Just me','Always yours'],'scarf':['Cosy scarf','Always yours'],'beret':['Artist beret','Make a picture together'],'explorer':['Explorer hat','Solve a puzzle together'],'astronaut':['Space helmet','Finish a story together']};
    return PageShell(title:'A little dress-up',child:ListView(padding:const EdgeInsets.all(24),children:[
      SizedBox(height:300,child:PetView(color:w.color,outfit:w.outfit,reducedMotion:w.reducedMotion)),
      Text('Who shall we imagine today?',textAlign:TextAlign.center,style:Theme.of(context).textTheme.titleLarge),const SizedBox(height:18),
      for(final e in items.entries)Padding(padding:const EdgeInsets.only(bottom:12),child:ListTile(minVerticalPadding:18,tileColor:w.outfit==e.key?Brand.mint:Colors.white,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(22)),leading:Icon(w.owned.contains(e.key)?Icons.checkroom_rounded:Icons.lock_outline_rounded),title:Text(e.value.first),subtitle:Text(e.value.last),trailing:w.outfit==e.key?const Icon(Icons.check_circle_rounded,color:Brand.sage):null,onTap:!w.owned.contains(e.key)?null:()=>app.change((next){next.outfit=e.key;next.dialogue=e.key=='astronaut'?'A space adventure? I have just the helmet!':'This feels like me!';if(e.key=='none')return next;return MemoryEngine().add(next,Memory(id:'outfit:${e.key}',kind:'outfit',title:'Our ${e.value.first.toLowerCase()}',topic:e.value.first.toLowerCase(),at:DateTime.now()));}))),
    ]));
  }
}
