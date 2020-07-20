import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:basketballstats/services/authenticationbloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../messages.dart';

///
/// Shows the current invites pending for this user.
///
class InviteCountBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext c) => InvitesBloc(
          db: RepositoryProvider.of<BasketballDatabase>(c),
          email: BlocProvider.of<AuthenticationBloc>(context).state.user.email),
      child: Builder(
        builder: (BuildContext context) => BlocBuilder(
          bloc: BlocProvider.of<InvitesBloc>(context),
          builder: (BuildContext context, InvitesBlocState state) {
            if (state.invites.length > 0) {
              Widget card = new Card(
                color: Colors.limeAccent,
                child: new ListTile(
                  leading: const Icon(MaterialIcons.email),
                  title: new Text(
                    Messages.of(context).invitedpeople(state.invites.length),
                  ),
                ),
              );
              return card;
            }

            return new SizedBox(
              width: 1.0,
            );
          },
        ),
      ),
    );
  }
}
